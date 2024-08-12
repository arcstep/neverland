defmodule NeverlandWeb.UserLoginLive do
  use NeverlandWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        登录到梦幻岛，管理你的智能体
        <:subtitle>
          还没有智能体？
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            免费申请
          </.link>
          属于你的智能体帐户！
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="电子邮箱" required />
        <.input field={@form[:password]} type="password" label="密码" required />

        <:actions>
          <.input
            field={@form[:remember_me]}
            type="checkbox"
            label="让浏览器记住我的登录状态"
          />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            忘记密码?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="正在登录..." class="w-full">
            登 录 <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
