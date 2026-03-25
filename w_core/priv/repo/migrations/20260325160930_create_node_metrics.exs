defmodule WCore.Repo.Migrations.CreateNodeMetrics do
  use Ecto.Migration

  def change do
    create table(:node_metrics) do
      add :status, :string
      add :total_events_processed, :integer
      add :last_payload, :map
      add :last_seen_at, :utc_datetime
      add :node_id, references(:nodes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:node_metrics, [:node_id])
  end
end
