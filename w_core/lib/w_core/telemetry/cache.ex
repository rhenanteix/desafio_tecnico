defmodule WCore.Telemetry.Cache do
  use GenServer

  @table :w_core_telemetry_cache

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def table, do: @table

  @impl true
  def init(state) do
    :ets.new(@table, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, state}
  end
end
