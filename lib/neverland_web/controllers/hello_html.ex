defmodule NeverlandWeb.HelloHTML do
  @moduledoc """
  """
  use NeverlandWeb, :html

  embed_templates "hello_html/*"

  attr :message, :string, required: true
  def greet(assigns) do
    ~H"""
    <h2>Hello World, from <%= @messenger %>!</h2>
    """
  end

end
