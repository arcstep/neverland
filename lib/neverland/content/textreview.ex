defmodule Neverland.Content.TextReview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "text_reviews" do
    field :source, :string
    field :owner, :string
    field :submitted_at, :naive_datetime
    field :content, :string
    field :risk, :boolean, default: false
    field :tags, {:array, :string}, default: []

    timestamps()
  end

  def changeset(text_review, attrs) do
    text_review
    |> cast(attrs, [:source, :owner, :submitted_at, :content, :risk, :tags])
    |> validate_required([:source, :owner, :submitted_at, :content])
  end
end
