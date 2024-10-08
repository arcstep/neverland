defmodule NeverlandWeb.Project.WritingLive.AskAI do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 
  # defp confirm_filename(filename) when filename == "" do
  #   random_filename = for _ <- 1..8, into: "", do: <<Enum.random(?a..?z)>>
  #   random_filename <> ".md"
  # end

  # defp confirm_filename(filename), do: filename

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-output"
        mode={:show}
        compponent_type={:input}
        title="输出文件"
        value_id="output_file"
        value={@param_output_file}
      />
      <hr style="margin: 10px 0;" />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-completed"
        mode={if @command == "from_outline" and @param_completed == "", do: :edit, else: :show}
        compponent_type={:input}
        title="已完成"
        value_id="completed"
        value={@param_completed}
      />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-knowledge"
        mode={:show}
        compponent_type={:input}
        title="背景资料"
        value_id="knowledge"
        value={@param_knowledge}
      />
      <hr style="margin: 10px 0;" />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-task"
        mode={if @command in ["idea", "outline"] and @param_task == "", do: :edit, else: :show}
        compponent_type={:textarea}
        title="写作任务"
        value_id="task"
        value={@param_task}
      />
      <div>
        <.button phx-click="ask-ai">提交</.button>
      </div>
    </div>
    """
  end
end
