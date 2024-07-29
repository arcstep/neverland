defmodule Neverland.Project.Info do
  use Ecto.Schema
  import Ecto.Changeset

  schema "infos" do
    field :title, :string
    field :description, :string
    field :public, :boolean
    field :owner, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(info, attrs) do
    info
    |> cast(attrs, [:title, :description, :public, :owner, :state])
    |> validate_required([:description, :public, :owner, :state])
    |> validate_inclusion(:state, ["todo", "done", "wait"])
  end
end
