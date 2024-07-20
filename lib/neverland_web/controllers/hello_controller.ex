defmodule NeverlandWeb.HelloController do
  use NeverlandWeb, :controller

  def world(conn, _params) do
    render(conn, :world)
  end

  def help(conn, _params) do
    render(conn, :help)
  end

  def show(conn, %{"messenger" => messenger}) do
    message = "你好哦"
    render(conn, :show, messenger: messenger, message: message)
  end

end
