defmodule NeverlandWeb.ProjectInfoLive.FormComponent do
  use NeverlandWeb, :live_component

  alias Neverland.Project

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>保存项目信息</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="info-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="标题" />
        <.input field={@form[:description]} type="text" label="描述" />
        <.input field={@form[:public]} type="checkbox" label="是否公开" />
        <.input field={@form[:state]} type="text" label="项目状态" />
        <:actions>
          <.button phx-disable-with="保存...">保存项目基本信息</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :infos, Project.list_infos())}
  end

  @impl true
  def update(%{info: info} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Project.change_info(info))
     end)}
  end

  @impl true
  def handle_event("validate", %{"info" => info_params}, socket) do
    changeset = Project.change_info(socket.assigns.info, info_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"info" => info_params}, socket) do
    IO.puts("save form: #{inspect(socket.assigns)}")
    save_info(socket, socket.assigns.action, info_params)
  end

  defp save_info(socket, :edit, info_params) do
    case Project.update_info(socket.assigns.info, info_params) do
      {:ok, info} ->
        notify_parent({:saved, info})

        {:noreply,
         socket
         |> put_flash(:info, "Info updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_info(socket, :new, info_params) do
    new_info_params =
      info_params
      |> Map.put("inserted_at", DateTime.utc_now())
      |> Map.put("updated_at", DateTime.utc_now())
      |> Map.put("owner", socket.assigns.email)

    case Project.create_info(new_info_params) do
      {:ok, info} ->
        notify_parent({:saved, info})

        {:noreply,
         socket
         |> put_flash(:info, "Info created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
