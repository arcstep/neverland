defmodule NeverlandWeb.HelloHTML do
  @moduledoc """
  """
  use NeverlandWeb, :html

  embed_templates "hello_html/*"

  attr :message, :string, required: true
  attr :messenger, :string, required: true
  def greet(assigns) do
    ~H"""
    <h2>来自 [<%= @messenger %>] 的消息: <%= @message %>!</h2>
    """
  end

end
