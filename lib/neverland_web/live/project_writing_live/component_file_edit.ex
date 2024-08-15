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
        title="输出文件"
        value_id="output_file"
        value={@param_output_file}
      />

      <textarea
        pid={@pid}
        id="markdown-editor"
        name="content"
        style="width: 100%; height: calc(100vh - 290px - 250px)"
      ><%= @param_content %></textarea>
      <.button phx-disable-with="保存...">保存</.button>
    </div>
    """
  end
end
