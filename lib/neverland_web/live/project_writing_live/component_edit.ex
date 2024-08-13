defmodule NeverlandWeb.Project.WritingLive.Component.Edit do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 style="display: flex; align-items: center; justify-content: space-between;">
        <span><%= @page_title %></span>
        <span>
          <button
            phx-click="new_item"
            style="background: none; border: none; cursor: pointer; margin: 0 5px"
            title="新建"
          >
            <i class="fas fa-plus"></i>
          </button>
          <button
            phx-click="rename_item"
            phx-value-name={@file_name}
            style="background: none; border: none; cursor: pointer; margin: 0 5px"
            title="重命名"
          >
            <i class="fas fa-edit"></i>
          </button>
          <button
            phx-click="remove_item"
            phx-value-name={@file_name}
            style="background: none; border: none; cursor: pointer; margin: 0 5px"
            title="移除"
          >
            <i class="fas fa-remove"></i>
          </button>
        </span>
      </h2>
      <%= if @file_name_mode == "new" do %>
        <div>
          <.input
            type="text"
            name="title"
            value={@file_name}
            placeholder="目标文件名称，例如：xxx.md"
            phx-blur="cancel_file_name_mode"
          />
        </div>
      <% end %>

      <.simple_form
        for={@form}
        id="writing-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <textarea
          id="markdown-editor"
          name="content"
          style="width: 100%; height: calc(100vh - 290px - 250px)"
        ><%= @form["raw_content"] %></textarea>
        <:actions>
          <.button phx-disable-with="保存...">保存</.button>
        </:actions>
      </.simple_form>
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
