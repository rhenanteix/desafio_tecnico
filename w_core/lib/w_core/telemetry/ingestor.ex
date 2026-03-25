defmodule WCore.Telemetry.Ingestor do
  use GenServer

  alias WCore.Telemetry.Cache

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def ingest(node_id, payload) do
    GenServer.cast(__MODULE__, {:ingest, node_id, payload})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:ingest, node_id, payload}, state) do
    timestamp = DateTime.utc_now()

    :ets.update_counter(
      Cache.table(),
      node_id,
      {3, 1},
      {node_id, :ok, 0, payload, timestamp}
    )

    {:noreply, state}
  end
end
