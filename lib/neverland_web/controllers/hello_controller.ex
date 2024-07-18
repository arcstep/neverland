defmodule NeverlandWeb.HelloController do
  use NeverlandWeb, :controller

  def world(conn, _params) do
    render(conn, :world, layout: false)
  end

  def help(conn, _params) do
    render(conn, :help, layout: false)
  end
end
