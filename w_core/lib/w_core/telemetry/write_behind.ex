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
    Cache.table()
    |> :ets.tab2list()
    |> Enum.each(&persist/1)
  end

  defp persist({node_id, status, count, payload, timestamp}) do
    Repo.insert!(
      %NodeMetric{
        node_id: node_id,
        status: status,
        total_events_processed: count,
        last_payload: payload,
        last_seen_at: timestamp
      },
      on_conflict: [
        set: [
          total_events_processed: count,
          last_payload: payload,
          last_seen_at: timestamp
        ]
      ],
      conflict_target: :node_id
    )
  end
end
