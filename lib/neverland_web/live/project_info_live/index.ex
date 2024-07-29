defmodule NeverlandWeb.Project.InfoLive.Index do
  use NeverlandWeb, :live_view

  alias Neverland.Project
  alias Neverland.Project.Info

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :infos, Project.list_infos())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Info")
    |> assign(:info, Project.get_info!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "创建新项目")
    |> assign(:info, %Info{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Infos")
    |> assign(:info, nil)
  end

  @impl true
  def handle_info({NeverlandWeb.InfoLive.FormComponent, {:saved, info}}, socket) do
    {:noreply, stream_insert(socket, :infos, info)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    info = Project.get_info!(id)
    {:ok, _} = Project.delete_info(info)

    {:noreply, stream_delete(socket, :infos, info)}
  end
end
