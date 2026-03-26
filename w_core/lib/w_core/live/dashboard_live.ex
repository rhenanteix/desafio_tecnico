defmodule WCoreWeb.DashboardLive do
  use WCoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WCore.PubSub, "telemetry")
    end

    nodes = load_from_ets()

    {:ok,
     socket
     |> stream(:nodes, nodes)}
  end


  @impl true
  def handle_info({:node_updated, node_id}, socket) do
    node = get_node_from_ets(node_id)

    {:noreply,
     stream_insert(socket, :nodes, node)}
  end

  defp load_from_ets do
    :ets.tab2list(:w_core_telemetry_cache)
    |> Enum.map(&format_node/1)
  end

  defp get_node_from_ets(node_id) do
    case :ets.lookup(:w_core_telemetry_cache, node_id) do
      [entry] -> format_node(entry)
      _ -> nil
    end
  end

  defp format_node({id, status, count, payload, ts}) do
    %{
      id: id,
      status: status,
      count: count,
      payload: payload,
      last_seen_at: ts
    }
  end

  defp status_class(:ok), do: "bg-green-100 border-green-400"
  defp status_class(:warning), do: "bg-yellow-100 border-yellow-400"
  defp status_class(:critical), do: "bg-red-200 border-red-500 animate-pulse"
end
