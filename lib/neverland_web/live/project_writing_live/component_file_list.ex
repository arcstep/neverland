defmodule NeverlandWeb.Project.WritingLive.Component.FileList do
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
            style={if file.path == @file_path, do: "color: #009688;", else: "color: #888888;"}
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
            phx-click="open_file"
            phx-value-path={file.path}
            phx-value-name={file.name}
            style={if file.path == @file_path, do: "text-decoration: underline;", else: ""}
          >
            <%= file.name %>
          </.link>
        </div>
      <% end %>
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
