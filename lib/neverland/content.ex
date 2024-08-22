defmodule Neverland.Content do
  alias Neverland.Repo
  alias Neverland.Content.TextReview

  def list_text_reviews do
    Repo.all(TextReview)
  end
end
