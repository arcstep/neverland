defmodule NeverlandWeb.UserController do
  use NeverlandWeb, :controller
  alias Neverland.Accounts

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    users = Accounts.list_users()
    conn
    |> put_flash(:info, "用户隐私，不要截屏！")
    |> assign(:users, users)
    |> render(:index)
  end
end
