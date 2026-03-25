defmodule WCore.TelemetryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WCore.Telemetry` context.
  """

  @doc """
  Generate a node_metric.
  """
  def node_metric_fixture(attrs \\ %{}) do
    {:ok, node_metric} =
      attrs
      |> Enum.into(%{
        last_payload: %{},
        last_seen_at: ~U[2026-03-24 16:09:00Z],
        status: "some status",
        total_events_processed: 42
      })
      |> WCore.Telemetry.create_node_metric()

    node_metric
  end
end
