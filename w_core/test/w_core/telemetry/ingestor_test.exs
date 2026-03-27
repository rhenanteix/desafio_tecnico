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
    total_events = 5000
    nodes = 50

    start_time = System.monotonic_time()

    # 🔥 CONCORRÊNCIA REAL (CORRETO)
    Task.async_stream(
      1..total_events,
      fn i ->
        WCore.Telemetry.Ingestor.ingest(
          rem(i, nodes),
          %{temp: Enum.random([60, 90, 120])}
        )
      end,
      max_concurrency: System.schedulers_online() * 4,
      timeout: :infinity
    )
    |> Stream.run()

    ingestion_time =
      System.monotonic_time() - start_time
      |> System.convert_time_unit(:native, :millisecond)

    # 🔥 pequeno delay para garantir processamento
    :timer.sleep(200)

    # =========================
    # ✅ ETS CHECK
    # =========================
    ets_entries = :ets.tab2list(:w_core_telemetry_cache)

    ets_total =
      ets_entries
      |> Enum.map(fn {_, _, count, _, _} -> count end)
      |> Enum.sum()

    assert ets_total == total_events

    # =========================
    # 🔥 FORCE FLUSH
    # =========================
    WCore.Telemetry.WriteBehind.flush_now()
    :timer.sleep(200)

    # =========================
    # ✅ DB CHECK
    # =========================
    db_entries = Repo.all(NodeMetric)

    db_total =
      db_entries
      |> Enum.map(& &1.total_events_processed)
      |> Enum.sum()

    assert db_total == total_events

    # =========================
    # 🔥 TESTES CRÍTICOS
    # =========================

    # ✅ 1. NÃO DUPLICOU NODES
    assert length(db_entries) == nodes

    # ✅ 2. TODOS OS NODES RECEBERAM EVENTOS
    Enum.each(db_entries, fn node ->
      assert node.total_events_processed > 0
    end)

    # ✅ 3. STATUS VÁLIDO
    Enum.each(db_entries, fn entry ->
      assert entry.status in ["ok", "warning", "critical"]
    end)

    # ✅ 4. ETS == DB (CONSISTÊNCIA)
    ets_map =
      ets_entries
      |> Map.new(fn {id, _status, count, _payload, _ts} ->
        {id, count}
      end)

    db_map =
      db_entries
      |> Map.new(fn node ->
        {node.node_id, node.total_events_processed}
      end)

    assert ets_map == db_map

    # ✅ 5. PERFORMANCE
    assert ingestion_time < 2000
  end

  test "write behind flushes automatically" do
    WCore.Telemetry.Ingestor.ingest(1, %{temp: 120})

    # espera flush automático (> intervalo de 5s)
    :timer.sleep(6000)

    result = Repo.all(NodeMetric)

    assert length(result) == 1

    # extra: valida status
    assert hd(result).status in ["ok", "warning", "critical"]
  end
end
