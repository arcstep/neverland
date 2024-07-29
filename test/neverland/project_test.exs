defmodule Neverland.ProjectTest do
  use Neverland.DataCase

  alias Neverland.Project

  describe "infos" do
    alias Neverland.Project.Info

    import Neverland.ProjectFixtures

    @invalid_attrs %{id: nil, owner: nil, public: nil, state: nil, description: nil, created_at: nil, updated_at: nil}

    test "list_infos/0 returns all infos" do
      info = info_fixture()
      assert Project.list_infos() == [info]
    end

    test "get_info!/1 returns the info with given id" do
      info = info_fixture()
      assert Project.get_info!(info.id) == info
    end

    test "create_info/1 with valid data creates a info" do
      valid_attrs = %{id: "some id", owner: "some owner", public: true, state: "some state", description: "some description", created_at: ~U[2024-07-28 03:13:00Z], updated_at: ~U[2024-07-28 03:13:00Z]}

      assert {:ok, %Info{} = info} = Project.create_info(valid_attrs)
      assert info.id == "some id"
      assert info.owner == "some owner"
      assert info.public == true
      assert info.state == "some state"
      assert info.description == "some description"
      assert info.created_at == ~U[2024-07-28 03:13:00Z]
      assert info.updated_at == ~U[2024-07-28 03:13:00Z]
    end

    test "create_info/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Project.create_info(@invalid_attrs)
    end

    test "update_info/2 with valid data updates the info" do
      info = info_fixture()
      update_attrs = %{id: "some updated id", owner: "some updated owner", public: false, state: "some updated state", description: "some updated description", created_at: ~U[2024-07-29 03:13:00Z], updated_at: ~U[2024-07-29 03:13:00Z]}

      assert {:ok, %Info{} = info} = Project.update_info(info, update_attrs)
      assert info.id == "some updated id"
      assert info.owner == "some updated owner"
      assert info.public == false
      assert info.state == "some updated state"
      assert info.description == "some updated description"
      assert info.created_at == ~U[2024-07-29 03:13:00Z]
      assert info.updated_at == ~U[2024-07-29 03:13:00Z]
    end

    test "update_info/2 with invalid data returns error changeset" do
      info = info_fixture()
      assert {:error, %Ecto.Changeset{}} = Project.update_info(info, @invalid_attrs)
      assert info == Project.get_info!(info.id)
    end

    test "delete_info/1 deletes the info" do
      info = info_fixture()
      assert {:ok, %Info{}} = Project.delete_info(info)
      assert_raise Ecto.NoResultsError, fn -> Project.get_info!(info.id) end
    end

    test "change_info/1 returns a info changeset" do
      info = info_fixture()
      assert %Ecto.Changeset{} = Project.change_info(info)
    end
  end
end
