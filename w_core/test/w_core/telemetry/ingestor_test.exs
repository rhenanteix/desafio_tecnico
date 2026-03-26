defmodule WCore.Telemetry.IngestorTest do
  use ExUnit.Case, async: false

  alias WCore.Telemetry.Ingestor
  alias WCore.Telemetry.NodeMetric
  alias WCore.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WCore.Repo)

    Ecto.Adapters.SQL.Sandbox.mode(WCore.Repo, {:shared, self()})

    # 👇 ESSENCIAL
    Ecto.Adapters.SQL.Sandbox.allow(
      WCore.Repo,
      self(),
      Process.whereis(WCore.Telemetry.WriteBehind)
    )

    :ok
  end

  defp random_status do
    Enum.random([:ok, :warning, :critical])
  end





  test "system is consistent under extreme concurrent load" do
    total_events = 10_000
    nodes = 100

    start_time = System.monotonic_time()

    tasks =
      for i <- 1..total_events do
        Task.async(fn ->
          node_id = rem(i, nodes)

          Ingestor.ingest(%{
            node_id: node_id,
            status: random_status(),
            payload: %{temp: Enum.random(60..120)}
          })
        end)
      end

    Task.await_many(tasks, 15_000)

    ingestion_time =
      System.monotonic_time() - start_time
      |> System.convert_time_unit(:native, :millisecond)

    # aguarda write-behind flush
    WCore.Telemetry.WriteBehind.flush_now()

    ets_entries = :ets.tab2list(:w_core_telemetry_cache)

    ets_total =
      ets_entries
      |> Enum.map(fn {_id, _status, count, _payload, _ts} -> count end)
      |> Enum.sum()

    db_total =
      Repo.all(NodeMetric)
      |> Enum.map(& &1.total_events_processed)
      |> Enum.sum()

    # 🔥 ASSERTS CRÍTICOS
    assert ets_total == total_events
    assert db_total == total_events

    # 🔥 PERFORMANCE
    assert ingestion_time < 2000

    IO.puts("Ingestion time: #{ingestion_time}ms")
  end
end
