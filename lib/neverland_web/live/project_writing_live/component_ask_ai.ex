defmodule NeverlandWeb.Project.WritingLive.AskAI do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-output"
        mode={:show}
        title="输出文件"
        value_id="output_file"
        value={@param_output_file}
      />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-task"
        mode={:show}
        title="写作任务"
        value_id="task"
        value={@param_task}
      />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-completed"
        mode={:show}
        title="已完成"
        value_id="completed"
        value={@param_completed}
      />
    </div>
    """
  end
end
