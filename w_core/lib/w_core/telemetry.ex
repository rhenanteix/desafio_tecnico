defmodule WCore.Telemetry do
  @moduledoc """
  The Telemetry context.
  """

  import Ecto.Query, warn: false
  alias WCore.Repo

  alias WCore.Telemetry.NodeMetric

  @doc """
  Returns the list of node_metrics.

  ## Examples

      iex> list_node_metrics()
      [%NodeMetric{}, ...]

  """
  def list_node_metrics do
    Repo.all(NodeMetric)
  end

  @doc """
  Gets a single node_metric.

  Raises `Ecto.NoResultsError` if the Node metric does not exist.

  ## Examples

      iex> get_node_metric!(123)
      %NodeMetric{}

      iex> get_node_metric!(456)
      ** (Ecto.NoResultsError)

  """
  def get_node_metric!(id), do: Repo.get!(NodeMetric, id)

  @doc """
  Creates a node_metric.

  ## Examples

      iex> create_node_metric(%{field: value})
      {:ok, %NodeMetric{}}

      iex> create_node_metric(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_node_metric(attrs) do
    %NodeMetric{}
    |> NodeMetric.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a node_metric.

  ## Examples

      iex> update_node_metric(node_metric, %{field: new_value})
      {:ok, %NodeMetric{}}

      iex> update_node_metric(node_metric, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_node_metric(%NodeMetric{} = node_metric, attrs) do
    node_metric
    |> NodeMetric.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a node_metric.

  ## Examples

      iex> delete_node_metric(node_metric)
      {:ok, %NodeMetric{}}

      iex> delete_node_metric(node_metric)
      {:error, %Ecto.Changeset{}}

  """
  def delete_node_metric(%NodeMetric{} = node_metric) do
    Repo.delete(node_metric)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking node_metric changes.

  ## Examples

      iex> change_node_metric(node_metric)
      %Ecto.Changeset{data: %NodeMetric{}}

  """
  def change_node_metric(%NodeMetric{} = node_metric, attrs \\ %{}) do
    NodeMetric.changeset(node_metric, attrs)
  end
end
