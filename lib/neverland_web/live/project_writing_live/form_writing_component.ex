defmodule NeverlandWeb.Project.WritingLive.FormComponent do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>保存项目信息</:subtitle>
      </.header>

      <.simple_form
        for={@input}
        id="info-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <fieldset>
          <legend>选择写作模式</legend>
          <div class="tools-panel">
            <div class="buttons flex flex-wrap gap-2">
              <input
                type="radio"
                name="action"
                id="action_idea"
                value="idea"
                checked={@input["action"] == "idea"}
              />
              <label for="action_idea" class="border rounded-lg p-2 bg-gray-200">
                创意
              </label>

              <input
                type="radio"
                name="action"
                id="action_outline"
                value="outline"
                checked={@input["action"] == "outline"}
              />
              <label for="action_outline" class="border rounded-lg p-2 bg-gray-200">
                提纲
              </label>

              <input
                type="radio"
                name="action"
                id="action_from_outline"
                value="from_outline"
                checked={@input["action"] == "from_outline"}
              />
              <label for="action_from_outline" class="border rounded-lg p-2 bg-gray-200">
                扩写
              </label>
            </div>
          </div>
        </fieldset>
        <div class="field">
          <label for="task">描述写作任务：</label>
          <.input type="text" name="task" value={@input["task"]} placeholder="描述你的任务" />
        </div>

        <div class="field">
          <label for="completed">整理思路草稿：</label>
          <.input
            type="text"
            name="completed"
            value={@input["completed"]}
            placeholder="草稿或已完成部分"
          />
        </div>

        <div class="field">
          <label for="knowledge">需要注意的知识背景：</label>
          <.input
            type="text"
            name="knowledge"
            value={@input["knowledge"]}
            placeholder="相关的知识背景"
          />
        </div>

        <:actions>
          <.button phx-disable-with="保存...">保存项目基本信息</.button>
        </:actions>

        <div class="markdown-body">
          <%= raw(@html_content) %>
        </div>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    IO.puts("mounting...#{inspect(socket)}")

    {
      :ok,
      socket
    }
  end

  @impl true
  def update(assigns, socket) do
    IO.puts("update: #{inspect(assigns)}")

    {
      :ok,
      socket
      |> assign(:input, assigns.input)
      |> assign(:title, "我的标题")
      |> assign(:html_content, "我的内容")
    }
  end

  @impl true
  def handle_event("validate", form_params, socket) do
    IO.puts("save_info from validate: #{inspect(form_params)}")
    {:noreply, socket}
  end

  def handle_event("save", form_params, socket) do
    save_info(socket, socket.assigns.action, form_params)
  end

  defp save_info(socket, :edit, form_params) do
    IO.puts("save_info from edit: #{inspect(form_params)}")

    {:noreply, socket}
  end

  defp save_info(socket, :new, form_params) do
    IO.puts("save_info from new: #{inspect(form_params)}")

    {:noreply, socket}
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
