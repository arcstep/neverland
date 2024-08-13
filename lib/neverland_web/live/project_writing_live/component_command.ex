defmodule NeverlandWeb.Project.WritingLive.Component.Command do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 style="display: flex; align-items: center; justify-content: space-between;">
        <span><%= @page_title %></span>
      </h2>
      <.input
        type="text"
        name="title"
        value={@page_title}
        placeholder="目标文件名称，例如：xxx.md"
      />
      <.simple_form
        for={@form}
        id="writing-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <textarea
          id="textlong-param-task"
          name="content"
          placeholder="任务描述"
          style="width: 100%;"
        ><%= @form["task"] %></textarea>
        <textarea
          id="textlong-param-completed"
          name="content"
          placeholder="草稿或已完成部分"
          style="width: 100%;"
        ><%= @form["completed"] %></textarea>
        <textarea
          id="textlong-param-knowledge"
          name="content"
          placeholder="背景资料"
          style="width: 100%;"
        ><%= @form["knowledge"] %></textarea>
        <:actions>
          <.button phx-disable-with="提交...">提交</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:form, %{"task" => "", "completed" => "", "knowledge" => ""})
    }
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
