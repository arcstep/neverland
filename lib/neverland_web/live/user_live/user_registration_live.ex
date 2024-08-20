defmodule NeverlandWeb.UserRegistrationLive do
  use NeverlandWeb, :live_view

  alias Neverland.Accounts
  alias Neverland.Accounts.User
  require Logger

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        申请一个智能体帐户
        <:subtitle>
          已经注册过了?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            直接登录
          </.link>
          管理你的智能体。
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          咦？你的资料中有什么不太对劲，赶紧检查一下吧！
        </.error>

        <.input field={@form[:email]} type="email" label="电子邮箱" required />
        <.input field={@form[:password]} type="password" label="密码" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">创建一个智能体</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        case Accounts.deliver_user_confirmation_instructions(
               user,
               &url(~p"/users/confirm/#{&1}")
             ) do
          {:ok, _} ->
            changeset = Accounts.change_user_registration(user)
            {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

          {:error, {:retries_exceeded, {:network_failure, host, reason}}} ->
            Logger.error("Network failure when trying to reach #{host}: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "Network error, please try again later.")}

          {:error, reason} ->
            Logger.error("Unexpected error: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "An unexpected error occurred.")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
