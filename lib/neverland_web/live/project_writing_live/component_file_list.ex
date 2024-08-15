defmodule NeverlandWeb.Project.WritingLive.FileList do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3 style="display: flex; align-items: center; justify-content: space-between;">
        <span>所有文件</span>
      </h3>
      <%= for file <- @file_list do %>
        <div>
          <span
            class="icon"
            style={if file.name == @param_output_file, do: "color: #009688;", else: "color: #888888;"}
          >
            <%= raw(
              case file.extension do
                "txt" -> "<i class=\"fas fa-solid fa-file-alt\"></i>"
                "md" -> "<i class=\"fas fa-file-code\"></i>"
                "mermaid" -> "<i class=\"fas fa-project-diagram\"></i>"
                "python" -> "<i class=\"fas fa-python\"></i>"
                "yaml" -> "<i class=\"fas fa-file-yaml\"></i>"
                "json" -> "<i class=\"fas fa-file-code\"></i>"
                "png" -> "<i class=\"fas fa-file-image\"></i>"
                "jpeg" -> "<i class=\"fas fa-file-image\"></i>"
                _ -> "<i class=\"fas fa-file\"></i>"
              end
            ) %>
          </span>
          <.link
            phx-click="update_file_list_selected"
            phx-value-path={file.path}
            phx-value-name={file.name}
            style={if file.name == @param_output_file, do: "text-decoration: underline;", else: ""}
          >
            <%= file.name %>
          </.link>
        </div>
      <% end %>
    </div>
    """
  end
end
