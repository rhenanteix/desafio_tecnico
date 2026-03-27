defmodule WCore.Telemetry.Cache do
  use GenServer

  @table :w_core_telemetry_cache

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [
          :named_table,
          :public,
          read_concurrency: true,
          write_concurrency: true
        ])

      _tid ->
        :ok
    end

    {:ok, state}
  end

  def table, do: @table
end
