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
        action={~p"/users/log_in"}
        method="get"
      >
        <.error :if={@check_errors}>
          请检查表单中的错误！
        </.error>

        <.input field={@form[:email]} type="email" label="帐户" required />
        <.input field={@form[:password]} type="password" label="密码" required />

        <div class="mt-4">
          <label>
            <input type="checkbox" phx-click="toggle_privacy_policy" checked={@privacy_policy} />
            我已阅读并同意
          </label>
          <a href="#" phx-click="show_privacy_policy" class="text-brand hover:underline">
            《用户同意条款》
          </a>
        </div>

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">创建一个智能体</.button>
        </:actions>
      </.simple_form>
    </div>

    <.modal
      :if={@show_privacy_policy}
      id="user-agree-modal"
      show
      on_cancel={JS.patch(~p"/users/register")}
    >
      <.live_component
        id="user-agree-form"
        module={NeverlandWeb.UserAggree.FormComponent}
        patch={~p"/users/register"}
      />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(
        trigger_submit: false,
        check_errors: false,
        show_privacy_policy: false,
        privacy_policy: false
      )
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    # IO.puts("register user: #{inspect(user_params)}")

    if not socket.assigns.privacy_policy do
      {:noreply, put_flash(socket, :error, "您必须同意《用户同意条款》才能注册。")}
    else
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
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    # IO.puts("validate user: #{inspect(user_params)}")
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("toggle_privacy_policy", _params, socket) do
    {:noreply, assign(socket, privacy_policy: !socket.assigns.privacy_policy)}
  end

  def handle_event("show_privacy_policy", _params, socket) do
    {:noreply, assign(socket, show_privacy_policy: true)}
  end

  def handle_event("close_privacy_policy", _params, socket) do
    {:noreply, assign(socket, show_privacy_policy: false)}
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: Phoenix.HTML.FormData.to_form(changeset, []))
  end
end
