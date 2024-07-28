defmodule NeverlandWeb.WrongLive do
  use NeverlandWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Your score: <%= @score %></h1>

    <h2>
      <%= @message %>
    </h2>
    <h2>
      <%= for n <- 1..10 do %>
        <.link href="#" phx-click="guess" phx-value-number={n}>
          <%= n %>
        </.link>
      <% end %>
    </h2>
    """
  end

  def mount(_params, session, socket) do
    {
      :ok,
      assign(
        socket,
        score: 2,
        message: "Guess a number.",
        session_id: session["live_socket_id"]
      )
    }
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    message = "Your guess: #{guess}. Wrong. Guess again. "
    score = socket.assigns.score + 1

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score
      )
    }
  end
end