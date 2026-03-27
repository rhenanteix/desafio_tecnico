defmodule WCore.Telemetry.Ingestor do
  use GenServer

  @table :w_core_telemetry_cache

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # ✅ NOVO (compatível com o teste)
  def ingest(node_id, payload) do
    GenServer.cast(__MODULE__, {:ingest, node_id, payload})
  end

  # (opcional - manter compatibilidade com versão antiga)
  def ingest(%{node_id: node_id, payload: payload}) do
    ingest(node_id, payload)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:ingest, node_id, payload}, state) do
    current_status =
      case :ets.lookup(@table, node_id) do
        [{_, status, _, _, _}] -> status
        _ -> nil
      end

    new_status =
      case payload[:temp] do
        temp when temp > 100 -> :critical
        temp when temp > 80 -> :warning
        _ -> :ok
      end

    now = DateTime.utc_now()

    :ets.insert(@table, {node_id, new_status, increment(node_id), payload, now})

    if current_status != new_status do
      Phoenix.PubSub.broadcast(
        WCore.PubSub,
        "telemetry",
        {:node_updated, node_id}
      )
    end

    {:noreply, state}
  end

  defp increment(node_id) do
    case :ets.lookup(@table, node_id) do
      [{_, _, count, _, _}] -> count + 1
      _ -> 1
    end
  end
end
