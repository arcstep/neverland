defmodule NeverlandWeb.Project.InfoLive.Index do
  use NeverlandWeb, :live_view

  alias Neverland.Project
  alias Neverland.Project.Info

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    # Project.list_infos(1, 10)
    infos = []

    {
      :ok,
      socket
      |> assign(email: user.email, page: 1, per_page: 10, cur_page_length: length(infos))
      |> stream(:infos, infos)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = socket.assigns.per_page
    infos = Project.list_infos(page, per_page)

    # IO.puts("page: #{page}, per_page: #{per_page}")

    {
      :noreply,
      socket
      |> assign(cur_page_length: length(infos), page: page, per_page: per_page)
      |> apply_action(socket.assigns.live_action, params)
      |> stream(:infos, infos)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "🦋 编辑项目信息")
    |> assign(:info, Project.get_info!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "🦋 创建新项目")
    |> assign(:info, %Info{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "🦋 Listing Infos")
    |> assign(:info, nil)
  end

  @impl true
  def handle_info({NeverlandWeb.ProjectInfoLive.FormComponent, {:saved, info}}, socket) do
    IO.puts("handle_info: #{inspect(info)}")
    {:noreply, stream_insert(socket, :infos, info)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    info = Project.get_info!(id)
    {:ok, _} = Project.delete_info(info)

    {:noreply, stream_delete(socket, :infos, info)}
  end
end
