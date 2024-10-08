defmodule NeverlandWeb.UserSessionController do
  use NeverlandWeb, :controller

  alias Neverland.Accounts
  alias NeverlandWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "登录成功！")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "密码更新成功!")
  end

  def create(conn, params) do
    create(conn, params, "欢迎回来!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      case user.confirmed_at do
        nil ->
          conn
          |> put_flash(:error, "请先验证您的帐户。")
          |> redirect(to: ~p"/users/log_in")

        _ ->
          conn
          |> put_flash(:info, info)
          |> UserAuth.log_in_user(user, user_params)
      end
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "无效的帐户名或密码")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "帐户退出成功。")
    |> UserAuth.log_out_user()
  end
end
