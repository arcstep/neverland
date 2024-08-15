defmodule NeverlandWeb.Project.WritingLive.Command.Idea do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Command.Param}
        pid={@pid}
        id="writing-param-output"
        mode={:show}
        title="输出文件"
        value_id="output_file"
        value={@param_output_file}
      />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Command.Param}
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
