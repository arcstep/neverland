defmodule Neverland.Accounts.UserNotifier do
  import Swoosh.Email

  alias Neverland.Mailer

  def send_email() do
    email =
      new()
      |> to("xuehongwei@illufly.com")
      |> from({"🦋 Neverland", "support@illufly.com"})
      |> subject("Test Email")
      |> text_body("This is a test email.")

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"🦋 Neverland", "support@illufly.com"})
      |> subject(subject)
      |> html_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "您正在申请 🦋 Neverland 帐户，请您24小时内确认邮件中的 Web 链接？", """
    <h1>感谢您注册 🦋Neverland 服务帐户</h1>
    <p>尊敬的 <b>#{user.email}</b>,</p>
    <p>您刚刚申请注册了 <a href="www.illufly.com">Neverland平台</a>专属的<b>AI服务</b>帐户，点击下面的确认链接即可正式生效：</p>
    <p><a href="#{url}">#{url}</a></p>
    <p>如果这不是您申请创建的，就请忽略此邮件。</p>
    <p>祝您使用愉快！</p>
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "💡 您正在重置 🦋 Neverland 帐户的密码", """
    <h1>您正在重置 🦋Neverland 服务帐户密码</h1>
    <p>尊敬的 <b>#{user.email}</b>, </p>
    <p>您正在修改帐户的密码，点击下面的确认链接即可重置：</p>
    <p><a href="#{url}">#{url}</a></p>
    <p>如果这不是您的请求，请忽略此邮件。</p>
    <p>祝您使用愉快！</p>
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "⚠️ 您刚刚修改了 🦋 Neverland 帐户的密码", """
    <h1>您正在修改 🦋Neverland 服务帐户密码</h1>
    <p>尊敬的 <b>#{user.email}</b>, </p>
    <p>您正在修改帐户的密码，点击下面的确认链接即可正式修改：</p>
    <p><a href="#{url}">#{url}</a></p>
    <p>如果这不是您的请求，请忽略此邮件。</p>
    <p>祝您使用愉快！</p>
    """)
  end
end
