defmodule NeverlandWeb.Project.WritingLive.Param do
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
            title={"修改" <> @title}
          >
            <i class="fas fa-edit"></i>
          </button>
        </span>
      </h2>
      <%= if @mode == :edit and @compponent_type == :input do %>
        <div style="display: flex; ">
          <.form for={%{}} phx-submit="save" phx-target={@myself} style="width: 100%;">
            <input id={@value_id} type="text" name={@value_id} value={@value} style="width: 70%;" />
            <button>保存</button>
            <button
              phx-click="cancel_edit"
              phx-target={@myself}
              style="background: none; border: none; cursor: pointer; margin: 0 5px"
              title="取消"
            >
              取消
            </button>
          </.form>
        </div>
      <% end %>
      <%= if @mode == :edit and @compponent_type == :textarea do %>
        <div style="display: flex; ">
          <.form for={%{}} phx-submit="save" phx-target={@myself} style="width: 100%;">
            <textarea pid={@pid} id={@value_id} name={@value_id} style="width: 70%;"><%= @value %></textarea>
            <button>保存</button>
            <button
              phx-click="cancel_edit"
              phx-target={@myself}
              style="background: none; border: none; cursor: pointer; margin: 0 5px"
              title="取消"
            >
              取消
            </button>
          </.form>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("save", value, socket) do
    IO.puts("save: #{inspect(value)} / #{inspect(socket.assigns)}")

    # 发送更新到父组件
    pid = :erlang.list_to_pid(socket.assigns.pid)
    send(pid, {:update_param, value})

    {
      :noreply,
      socket
      |> assign(:mode, :show)
    }
  end

  def handle_event("edit_param", _, socket) do
    {
      :noreply,
      socket
      |> assign(:mode, :edit)
    }
  end

  def handle_event("cancel_edit", _, socket) do
    {
      :noreply,
      socket
      |> assign(:mode, :show)
    }
  end
end
