defmodule NeverlandWeb.UserForgotPasswordLive do
  use NeverlandWeb, :live_view

  alias Neverland.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        忘记密码了?
        <:subtitle>别着急，我们会向你的邮箱发送一个密码重置链接</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            发送密码重置邮件
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"}>注册</.link> | <.link href={~p"/users/log_in"}>登录</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "如果你的电子邮箱在我们的系统中，你应当马上能收到一封重置密码的电子邮件。"

    {
      :noreply,
      socket
      |> put_flash(:info, info)
      |> redirect(to: ~p"/")
    }
  end
end
