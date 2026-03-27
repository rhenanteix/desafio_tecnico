defmodule WCore.Telemetry.IngestorTest do
  use ExUnit.Case, async: false

  alias WCore.Repo
  alias WCore.Telemetry.NodeMetric

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WCore.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(WCore.Repo, {:shared, self()})

    :ets.delete_all_objects(:w_core_telemetry_cache)
    Repo.delete_all(NodeMetric)

    :ok
  end

  test "system is consistent under concurrent load" do
    total_events = 5_000
    nodes = 50

    tasks =
      for i <- 1..total_events do
        Task.async(fn ->
          WCore.Telemetry.Ingestor.ingest(%{
            node_id: rem(i, nodes),
            payload: %{temp: Enum.random([60, 90, 120])}
          })
        end)
      end

    Task.await_many(tasks, 15_000)

    :timer.sleep(6_000)

    ets_total =
      :ets.tab2list(:w_core_telemetry_cache)
      |> Enum.map(fn {_id, _status, count, _, _} -> count end)
      |> Enum.sum()

    db_total =
      Repo.all(NodeMetric)
      |> Enum.map(& &1.total_events_processed)
      |> Enum.sum()

    assert ets_total == total_events
    assert db_total == total_events
  end
end
