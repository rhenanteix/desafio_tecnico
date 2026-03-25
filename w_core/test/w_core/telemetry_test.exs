defmodule WCore.TelemetryTest do
  use WCore.DataCase

  alias WCore.Telemetry

  describe "node_metrics" do
    alias WCore.Telemetry.NodeMetric

    import WCore.TelemetryFixtures

    @invalid_attrs %{status: nil, total_events_processed: nil, last_payload: nil, last_seen_at: nil}

    test "list_node_metrics/0 returns all node_metrics" do
      node_metric = node_metric_fixture()
      assert Telemetry.list_node_metrics() == [node_metric]
    end

    test "get_node_metric!/1 returns the node_metric with given id" do
      node_metric = node_metric_fixture()
      assert Telemetry.get_node_metric!(node_metric.id) == node_metric
    end

    test "create_node_metric/1 with valid data creates a node_metric" do
      valid_attrs = %{status: "some status", total_events_processed: 42, last_payload: %{}, last_seen_at: ~U[2026-03-24 16:09:00Z]}

      assert {:ok, %NodeMetric{} = node_metric} = Telemetry.create_node_metric(valid_attrs)
      assert node_metric.status == "some status"
      assert node_metric.total_events_processed == 42
      assert node_metric.last_payload == %{}
      assert node_metric.last_seen_at == ~U[2026-03-24 16:09:00Z]
    end

    test "create_node_metric/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Telemetry.create_node_metric(@invalid_attrs)
    end

    test "update_node_metric/2 with valid data updates the node_metric" do
      node_metric = node_metric_fixture()
      update_attrs = %{status: "some updated status", total_events_processed: 43, last_payload: %{}, last_seen_at: ~U[2026-03-25 16:09:00Z]}

      assert {:ok, %NodeMetric{} = node_metric} = Telemetry.update_node_metric(node_metric, update_attrs)
      assert node_metric.status == "some updated status"
      assert node_metric.total_events_processed == 43
      assert node_metric.last_payload == %{}
      assert node_metric.last_seen_at == ~U[2026-03-25 16:09:00Z]
    end

    test "update_node_metric/2 with invalid data returns error changeset" do
      node_metric = node_metric_fixture()
      assert {:error, %Ecto.Changeset{}} = Telemetry.update_node_metric(node_metric, @invalid_attrs)
      assert node_metric == Telemetry.get_node_metric!(node_metric.id)
    end

    test "delete_node_metric/1 deletes the node_metric" do
      node_metric = node_metric_fixture()
      assert {:ok, %NodeMetric{}} = Telemetry.delete_node_metric(node_metric)
      assert_raise Ecto.NoResultsError, fn -> Telemetry.get_node_metric!(node_metric.id) end
    end

    test "change_node_metric/1 returns a node_metric changeset" do
      node_metric = node_metric_fixture()
      assert %Ecto.Changeset{} = Telemetry.change_node_metric(node_metric)
    end
  end
end
