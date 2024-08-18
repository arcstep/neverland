defmodule NeverlandWeb.Project.WritingLive.Edit do
  use NeverlandWeb, :live_view

  alias Neverland.Project
  alias Neverland.Project.Resource
  alias Neverland.Sandbox.Python

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:pid, :erlang.pid_to_list(self()))
      |> assign(:command, "edit")
      |> assign(:param_output_file, "")
      |> assign(:param_task, "")
      |> assign(:param_completed, "")
      |> assign(:param_knowledge, "")
      |> assign(:param_content, "")
      |> assign(:raw_log, "")
      |> assign(:html_content, "")
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    thread_id = "#{socket.assigns.current_user.email}:#{id}"
    project_info = Project.get_info!(id)

    {:ok, thread_id} =
      Python.run(:sandbox_python, "chat_with_textlong.py", self(), thread_id)

    Python.input(:sandbox_python, project_info.title, thread_id)

    {
      :noreply,
      socket
      |> assign(:project_id, id)
      |> assign(:thread_id, thread_id)
      |> refresh_file_list(id)
    }
  end

  defp refresh_file_list(socket, id) do
    project_info = Project.get_info!(id)
    file_list = Resource.file_list(project_info.title)

    socket
    |> assign(:info, Project.get_info!(id))
    |> assign(:file_list, file_list)
  end

  @impl true
  def handle_event("cancel_file_select", _param, socket) do
    {
      :noreply,
      socket
      |> assign(:param_output_file, "")
    }
  end

  def handle_event("update_header_choose_command", %{"value" => command}, socket) do
    IO.puts("choose_command: #{inspect(command)}")

    {
      :noreply,
      socket
      |> assign(:command, command)
    }
  end

  def handle_event("update_param_value", value, socket) do
    IO.puts("update_param_value: #{inspect(value)}")

    {
      :noreply,
      socket
    }
  end

  def handle_event(
        "update_file_list_selected",
        %{"path" => file_path, "name" => file_name},
        socket
      ) do
    {:ok, raw_content} = File.read(file_path)

    {
      :noreply,
      socket
      |> assign(:param_output_file, file_name)
      |> assign(:param_content, raw_content)
    }
  end

  def handle_event("get-command", _, socket) do
    IO.puts(
      "get-command: " <>
        "#{socket.assigns.command}, " <>
        "#{socket.assigns.param_task}, " <>
        "#{socket.assigns.param_completed}, " <>
        "#{socket.assigns.param_knowledge}, " <>
        "#{socket.assigns.param_output_file}"
    )

    {
      :noreply,
      socket
    }
  end

  def handle_event("ask-ai", _params, socket) do
    thread_id = socket.assigns.thread_id
    task = socket.assigns.param_task
    completed = socket.assigns.param_completed
    knowledge = socket.assigns.param_knowledge
    output_file = socket.assigns.param_output_file
    action = socket.assigns.command

    # 根据action执行不同的逻辑
    cmd =
      case action do
        "idea" ->
          "p.idea(task='#{task}', completed='#{completed}', knowledge='#{knowledge}', output_file='#{output_file}')"

        "outline" ->
          "p.outline(task='#{task}', completed='#{completed}', knowledge='#{knowledge}', output_file='#{output_file}'))"

        "from_outline" ->
          "p.from_outline(task='#{task}', completed='#{completed}', knowledge='#{knowledge}', output_file='#{output_file}'))"

        _ ->
          # 默认处理
          ""
      end

    Python.input(:sandbox_python, cmd, thread_id)

    # 返回更新后的socket
    {:noreply, socket}
  end

  @impl true
  def handle_info({:thread_id, thread_id, :event, event, :output, output}, socket) do
    if thread_id != socket.assigns.thread_id do
      IO.puts("receive OTHER thread_id: #{thread_id}")
      {:noreply, socket}
    else
      # IO.puts("handling info...#{event}: #{inspect(output)}")
      socket_with_file_list =
        case event do
          "END" -> socket |> refresh_file_list(socket.assigns.project_id)
          _ -> socket
        end

      new_raw_log = socket.assigns.raw_log <> output

      html_content = convert_to_html(new_raw_log)
      # IO.puts("handling info...#{inspect(html_content)}")

      {
        :noreply,
        socket_with_file_list
        |> assign(:raw_log, new_raw_log)
        |> assign(:html_content, html_content)
      }
    end
  end

  def handle_info({:update_param, %{"output_file" => output_file}}, socket) do
    IO.puts("update_param: #{inspect(output_file)}")

    {
      :noreply,
      socket
      |> assign(param_output_file: output_file)
    }
  end

  def handle_info({:update_param, %{"task" => task}}, socket) do
    IO.puts("update_param: #{inspect(task)}")

    {
      :noreply,
      socket
      |> assign(:param_task, task)
    }
  end

  def handle_info({:update_param, %{"completed" => completed}}, socket) do
    IO.puts("update_param: #{inspect(completed)}")

    {
      :noreply,
      socket
      |> assign(:param_completed, completed)
    }
  end

  def handle_info({:update_param, %{"knowledge" => knowledge}}, socket) do
    IO.puts("update_param: #{inspect(knowledge)}")

    {
      :noreply,
      socket
      |> assign(:param_knowledge, knowledge)
    }
  end

  def handle_info({:update_param, %{"content" => content}}, socket) do
    IO.puts("update_param: #{inspect(content)}")

    {
      :noreply,
      socket
      |> assign(:param_content, content)
    }
  end

  defp convert_to_html(raw_content) do
    options = %Earmark.Options{gfm: true, breaks: true}
    Earmark.as_html!(raw_content, options)
  end

  # defp confirm_filename(filename) when filename == "" do
  #   random_filename = for _ <- 1..8, into: "", do: <<Enum.random(?a..?z)>>
  #   random_filename <> ".md"
  # end

  # defp confirm_filename(filename), do: filename

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
