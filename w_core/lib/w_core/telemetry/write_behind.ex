defmodule WCore.Telemetry.WriteBehind do
  use GenServer

  alias WCore.Telemetry.Cache
  alias WCore.Repo
  alias WCore.Telemetry.NodeMetric

  @interval 5_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_flush()
    {:ok, state}
  end

  def handle_info(:flush, state) do
    flush_to_db()
    schedule_flush()
    {:noreply, state}
  end

  defp schedule_flush do
    Process.send_after(self(), :flush, @interval)
  end

  defp flush_to_db do
    persist()
  end

  defp persist do
    table = Cache.table()

    entries =
      :ets.tab2list(table)
      |> Enum.map(fn {node_id, status, count, payload, timestamp} ->
        %{
          node_id: node_id,
          status: Atom.to_string(status),
          total_events_processed: count,
          last_payload: payload,
          last_seen_at: timestamp,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    case entries do
      [] ->
        :ok

      _ ->
        Repo.insert_all(
          NodeMetric,
          entries,
          on_conflict: {:replace, [
            :status,
            :total_events_processed,
            :last_payload,
            :last_seen_at,
            :updated_at
          ]},
          conflict_target: [:node_id]
        )
    end
  end
end
