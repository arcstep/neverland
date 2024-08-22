defmodule Neverland.Repo.Migrations.CreateTextReviews do
  use Ecto.Migration

  def change do
    create table(:text_reviews) do
      add :source, :string
      add :owner, :string
      add :submitted_at, :naive_datetime
      add :content, :text
      add :risk, :boolean, default: false
      add :tags, {:array, :string}, default: []

      timestamps()
    end
  end
end
