defmodule NeverlandWeb.Project.WritingLive.Edit do
  use NeverlandWeb, :live_view

  alias Neverland.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, thread_id} =
      Neverland.SandboxPython.run(:sandbox_python, "chat_with_textlong.py", self())

    {:ok,
     socket
     |> assign(:html_content, "")
     |> assign(:thread_id, thread_id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:info, Project.get_info!(id))}
  end

  defp page_title(:show), do: "🦋 项目文档查看"
  defp page_title(:edit), do: "🦋 AI写作"

  @impl true
  def handle_event("list_resource", _value, socket) do
    thread_id = socket.assigns.thread_id
    Neverland.SandboxPython.input(:sandbox_python, "p.list_resource()", thread_id)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:thread_id, _thread_id, :event, _event, :output, output}, socket) do
    IO.inspect("handling info...#{inspect(output)}")

    _markdown_content = """
    # 这是一个标题

    这是一个段落，用于展示如何在 Phoenix LiveView 中渲染 Markdown 内容。
    """

    html_content = Earmark.as_html!(output)

    {:noreply, assign(socket, :html_content, html_content)}
  end
end
