defmodule Neverland.ProjectFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Neverland.Project` context.
  """

  @doc """
  Generate a info.
  """
  def info_fixture(attrs \\ %{}) do
    {:ok, info} =
      attrs
      |> Enum.into(%{
        created_at: ~U[2024-07-28 03:13:00Z],
        description: "some description",
        id: "some id",
        owner: "some owner",
        public: true,
        state: "some state",
        updated_at: ~U[2024-07-28 03:13:00Z]
      })
      |> Neverland.Project.create_info()

    info
  end
end
