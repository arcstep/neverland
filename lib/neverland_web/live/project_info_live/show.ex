defmodule NeverlandWeb.Project.InfoLive.Show do
  use NeverlandWeb, :live_view

  alias Neverland.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:info, Project.get_info!(id))}
  end

  defp page_title(:show), do: "🦋 项目基本信息"
  defp page_title(:edit), do: "🦋 编辑项目基本信息"
end
