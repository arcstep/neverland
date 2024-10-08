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
        phx-submit="save_project"
      >
        <.input field={@form[:title]} type="text" label="标题" />
        <.input field={@form[:description]} type="text" label="描述" />
        <.input field={@form[:public]} type="checkbox" label="是否公开" />
        <:actions>
          <.button phx-disable-with="保存...">保存项目基本信息</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :infos, Project.list_infos(1, 10))}
  end

  @impl true
  def update(%{info: info} = assigns, socket) do
    new_info =
      case info.id do
        nil ->
          Project.new_info(%{}).data

        _ ->
          info
      end

    IO.puts("update_info: #{inspect(new_info)}")

    # IO.puts("info: #{inspect(info)}")
    # IO.puts("new_info: #{inspect(new_info)}")
    changeset = Project.change_info(new_info)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(changeset)
      end)
    }
  end

  @impl true
  def handle_event("validate", %{"info" => info_params}, socket) do
    changeset = Project.change_info(socket.assigns.info, info_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save_project", %{"info" => info_params}, socket) do
    IO.puts("save_info: #{inspect(info_params)}")
    save_info(socket, socket.assigns.action, info_params)
  end

  defp save_info(socket, :edit, info_params) do
    IO.puts("edit_info: #{inspect(info_params)}")

    case Project.update_info(socket.assigns.info, info_params) do
      {:ok, info} ->
        notify_parent({:saved, info})

        {
          :noreply,
          socket
          |> put_flash(:info, "Info updated successfully")
          |> push_patch(to: socket.assigns.patch)
        }

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

        {
          :noreply,
          socket
          |> put_flash(:info, "Info created successfully")
          |> push_patch(to: socket.assigns.patch)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
