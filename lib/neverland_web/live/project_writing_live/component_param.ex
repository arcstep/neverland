defmodule NeverlandWeb.Project.WritingLive.Component.Param do
  use NeverlandWeb, :live_component
  # use Phoenix.LiveComponent

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 style="display: flex; align-items: center; justify-content: space-between;">
        <span>
          <%= @title <> ": " <> @value %>
          <button
            phx-click="edit_param"
            phx-target={@myself}
            style="background: none; border: none; cursor: pointer; margin: 0 5px"
            title="新建"
          >
            <i class="fas fa-edit"></i>
          </button>
        </span>
      </h2>
      <%= if @mode == :edit do %>
        <div style="display: flex; ">
          <.input type="text" name="title" value={@value} placeholder="请输入..." />
          <button
            phx-click="cancel_edit"
            phx-target={@myself}
            style="background: none; border: none; cursor: pointer; margin: 0 5px"
            title="关闭"
          >
            <i class="fas fa-close" style="margin: 0 5px"></i>关闭
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("edit_param", value, socket) do
    IO.puts("edit_param: #{inspect(value)}")

    {
      :noreply,
      socket
      |> assign(:mode, :edit)
    }
  end

  def handle_event("cancel_edit", value, socket) do
    IO.puts("cancel_edit: #{inspect(value)}")

    {
      :noreply,
      socket
      |> assign(:mode, :show)
    }
  end
end
