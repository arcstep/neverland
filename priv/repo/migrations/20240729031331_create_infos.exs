defmodule Neverland.Repo.Migrations.CreateInfos do
  use Ecto.Migration

  def change do
    create table(:infos) do
      add :title, :string
      add :description, :string
      add :public, :boolean, default: false, null: false
      add :owner, :string
      add :state, :string

      timestamps(type: :utc_datetime)
    end
  end
end
