defmodule NeverlandWeb.Project.WritingLive.Edit do
  use NeverlandWeb, :live_view

  alias Neverland.Project
  alias Neverland.Project.Resource
  alias Neverland.Sandbox.Python

  @impl true
  def mount(_params, _session, socket) do
    IO.puts("\n[ mount ]: #{inspect(socket)}")

    raw_content = "# 这是一个测试内容\n嗯嗯，我今天的感觉还不错"
    html_content = convert_to_html(raw_content)
    thread_id = "#{socket.assigns.current_user.email}"

    {:ok, thread_id} =
      Python.run(:sandbox_python, "chat_with_textlong.py", self(), thread_id)

    {
      :ok,
      socket
      |> assign(:file_path, "")
      |> assign(:file_name, "")
      |> assign(:input, %{"action" => "idea", "task" => "", "completed" => "", "knowledge" => ""})
      |> assign(:form, %{"raw_content" => raw_content})
      # |> assign(:raw_content, raw_content)
      |> assign(:html_content, html_content)
      |> assign(:thread_id, thread_id)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    IO.puts("\n[ handle_params ]: #{inspect(socket)}")
    project_info = Project.get_info!(id)
    IO.puts("\n[ project_info ]: #{inspect(project_info.title)}")
    file_list = Resource.file_list(project_info.title)

    {
      :noreply,
      socket
      |> assign(:input, %{"action" => "idea", "task" => "", "completed" => "", "knowledge" => ""})
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:project_id, id)
      |> assign(:info, Project.get_info!(id))
      |> assign(:file_list, file_list)
    }
  end

  defp page_title(action, file_name \\ "")
  defp page_title(:show, file_name), do: "🦋 项目文档查看" <> file_name
  defp page_title(:gen, file_name), do: "🦋 AI写作" <> file_name
  defp page_title(:edit, file_name), do: "🦋 直接编辑" <> file_name

  @impl true
  def handle_event("list_resource", _value, socket) do
    thread_id = socket.assigns.thread_id
    Python.input(:sandbox_python, "p.list_resource()", thread_id)

    {:noreply, socket}
  end

  def handle_event("open_file", %{"path" => file_path, "name" => file_name}, socket) do
    {:ok, raw_content} = File.read(file_path)
    IO.puts("open_file: #{inspect(raw_content)}")

    {
      :noreply,
      socket
      |> assign(:file_path, file_path)
      |> assign(:file_name, file_name)
      |> assign(:page_title, page_title(socket.assigns.live_action, ": [ #{file_name} ]"))
      |> assign(:form, %{"raw_content" => raw_content})
    }
  end

  def handle_event("new_item", _params, socket) do
    # 处理新建事件的逻辑
    {:noreply, socket}
  end

  def handle_event("rename_item", params, socket) do
    # 处理重命名事件的逻辑
    IO.puts("rename_item: #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event("remove_item", params, socket) do
    # 处理移除事件的逻辑
    IO.puts("remove_item: #{inspect(params)}")
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

    Python.input(:sandbox_python, cmd, thread_id)
    # IO.puts("idea: #{completed}, #{knowledge}, #{task}, #{action}")

    # 返回更新后的socket
    {:noreply, socket}
  end

  @impl true
  def handle_info({:thread_id, _thread_id, :event, _event, :output, output}, socket) do
    IO.puts("handling info...#{inspect(output)}")

    new_raw_content = socket.assigns.raw_content <> output

    html_content = convert_to_html(new_raw_content)
    IO.puts("handling info...#{inspect(html_content)}")

    {
      :noreply,
      socket
      |> assign(:raw_content, new_raw_content)
      |> assign(:html_content, html_content)
    }
  end

  defp convert_to_html(raw_content) do
    options = %Earmark.Options{gfm: true, breaks: true}
    Earmark.as_html!(raw_content, options)
  end

  # @impl true
  # def terminate(reason, socket) do
  #   IO.puts("LiveView terminated: #{inspect(reason)}")

  #   # 在 LiveView 终止时执行清理工作
  #   # reason 参数可以是 :shutdown 或其他值，表示终止的原因
  #   # 这里可以执行任何必要的清理，例如取消订阅、关闭数据库连接等
  #   thread_id = socket.assigns.thread_id
  #   Python.input(:sandbox_python, "exit", thread_id)
  #   :ok
  # end
end
