defmodule NeverlandWeb.UserHTML do
  @moduledoc """
  """
  use NeverlandWeb, :html
  alias Neverland.Accounts

  def first_name(%Accounts.User{name: name}) do
    name
      |> String.split(" ")
      |> Enum.at(0)
  end

  embed_templates "user_html/*"
end
