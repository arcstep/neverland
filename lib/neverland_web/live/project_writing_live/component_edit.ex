defmodule NeverlandWeb.Project.WritingLive.Component.FileEdit do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Component.Param}
        id="writing-param-output"
        mode={:show}
        title="输出文件"
        value={@param_output_file}
      />
      <.live_component
        module={NeverlandWeb.Project.WritingLive.Component.Param}
        id="writing-param-completed"
        mode={:show}
        title="已完成"
        value={@param_completed}
      />

      <textarea
        id="markdown-editor"
        name="content"
        style="width: 100%; height: calc(100vh - 290px - 250px)"
      ><%= @param_content %></textarea>
      <.button phx-disable-with="保存...">保存</.button>
    </div>
    """
  end

  @impl true
  def handle_event("validate", form_params, socket) do
    IO.puts("validate: #{inspect(form_params)}")
    {:noreply, socket}
  end

  def handle_event("save", form_params, socket) do
    IO.puts("save: #{inspect(form_params)}")
    {:noreply, socket}
  end
end
