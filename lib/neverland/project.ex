defmodule Neverland.Project do
  @moduledoc """
  The Project context.
  """

  import Ecto.Query, warn: false
  alias Neverland.Repo

  alias Neverland.Project.Info

  @doc """
  Returns the list of infos.

  ## Examples

      iex> list_infos()
      [%Info{}, ...]

  """
  def list_infos(page, per_page) do
    Info
    |> order_by([i], desc: i.inserted_at)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  @doc """
  Gets a single info.

  Raises `Ecto.NoResultsError` if the Info does not exist.

  ## Examples

      iex> get_info!(123)
      %Info{}

      iex> get_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_info!(id), do: Repo.get!(Info, id)

  @doc """
  Creates a info.

  ## Examples

      iex> create_info(%{field: value})
      {:ok, %Info{}}

      iex> create_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_info(attrs \\ %{}) do
    new_info(attrs)
    |> Repo.insert()
  end

  def new_info(attrs \\ %{}) do
    %Info{public: false, state: "wait", title: "项目标题", description: "项目描述"}
    |> Info.changeset(attrs)
  end

  @doc """
  Updates a info.

  ## Examples

      iex> update_info(info, %{field: new_value})
      {:ok, %Info{}}

      iex> update_info(info, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_info(%Info{} = info, attrs) do
    info
    |> Info.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a info.

  ## Examples

      iex> delete_info(info)
      {:ok, %Info{}}

      iex> delete_info(info)
      {:error, %Ecto.Changeset{}}

  """
  def delete_info(%Info{} = info) do
    Repo.delete(info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking info changes.

  ## Examples

      iex> change_info(info)
      %Ecto.Changeset{data: %Info{}}

  """
  def change_info(%Info{} = info, attrs \\ %{}) do
    Info.changeset(info, attrs)
  end

  @doc """
  获得项目的文件位置路径。
  """
  def get_project_path(id) do
    # 从配置文件中获得项目文件所在的路径
    "#{Application.get_env(:neverland, :project_path)}/#{id}"
  end
end
