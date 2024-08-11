defmodule NeverlandWeb.Project.WritingLive.FormComponent.Edit do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="writing-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <textarea id="markdown-editor" name="content" style="width: 100%; height: 60vh"><%= @form["raw_content"] %></textarea>
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
