defmodule NeverlandWeb.Project.WritingLive.Edit do
  use NeverlandWeb, :live_view

  alias Neverland.Project

  @impl true
  def mount(_params, _session, socket) do
    IO.puts("LiveView mounted")

    thread_id = "#{socket.assigns.current_user.email}"

    {:ok, thread_id} =
      Neverland.SandboxPython.run(:sandbox_python, "chat_with_textlong.py", self(), thread_id)

    {
      :ok,
      socket
      |> assign(:input, %{"action" => "idea", "task" => "", "completed" => "", "knowledge" => ""})
      |> assign(:raw_content, "")
      |> assign(:html_content, "")
      |> assign(:thread_id, thread_id)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:info, Project.get_info!(id))
    }
  end

  defp page_title(:show), do: "🦋 项目文档查看"
  defp page_title(:edit), do: "🦋 AI写作"

  @impl true
  def handle_event("list_resource", _value, socket) do
    thread_id = socket.assigns.thread_id
    Neverland.SandboxPython.input(:sandbox_python, "p.list_resource()", thread_id)

    {:noreply, socket}
  end

  def handle_event("change_form", _params, socket) do
    # IO.puts("change_form: #{inspect(params)}")

    {:noreply, socket}
  end

  def handle_event("submit_form", params, socket) do
    thread_id = socket.assigns.thread_id

    # 获取表单参数
    task = params["task"]
    completed = params["completed"]
    knowledge = params["knowledge"]
    action = params["action"]

    # 根据action执行不同的逻辑
    cmd =
      case action do
        "idea" ->
          "p.idea(task='#{task}', completed='#{completed}', knowledge='#{knowledge}')"

        "outline" ->
          "p.outline(task='#{task}', completed='#{completed}', knowledge='#{knowledge}')"

        "from_outline" ->
          "p.from_outline(task='#{task}', completed='#{completed}', knowledge='#{knowledge}')"

        _ ->
          # 默认处理
          ""
      end

    Neverland.SandboxPython.input(:sandbox_python, cmd, thread_id)
    # IO.puts("idea: #{completed}, #{knowledge}, #{task}, #{action}")

    # 返回更新后的socket
    {:noreply, socket}
  end

  @impl true
  def handle_info({:thread_id, _thread_id, :event, _event, :output, output}, socket) do
    IO.inspect("handling info...#{inspect(output)}")

    new_raw_content = socket.assigns.raw_content <> output

    options = %Earmark.Options{gfm: true, breaks: true}
    html_content = Earmark.as_html!(new_raw_content, options)
    IO.inspect("handling info...#{inspect(html_content)}")

    {
      :noreply,
      socket
      |> assign(:raw_content, new_raw_content)
      |> assign(:html_content, html_content)
    }
  end

  # @impl true
  # def terminate(reason, socket) do
  #   IO.puts("LiveView terminated: #{inspect(reason)}")

  #   # 在 LiveView 终止时执行清理工作
  #   # reason 参数可以是 :shutdown 或其他值，表示终止的原因
  #   # 这里可以执行任何必要的清理，例如取消订阅、关闭数据库连接等
  #   thread_id = socket.assigns.thread_id
  #   Neverland.SandboxPython.input(:sandbox_python, "exit", thread_id)
  #   :ok
  # end
end
