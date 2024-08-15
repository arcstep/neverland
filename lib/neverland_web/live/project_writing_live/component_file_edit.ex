defmodule NeverlandWeb.Project.WritingLive.FileEdit do
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
        compponent_type={:input}
        title="输出文件"
        value_id="output_file"
        value={@param_output_file}
      />

      <.live_component
        module={NeverlandWeb.Project.WritingLive.Param}
        pid={@pid}
        id="writing-param-content"
        mode={:edit}
        compponent_type={:textarea}
        title="文本内容"
        value_id="content"
        value={@param_content}
      />
    </div>
    """
  end
end
