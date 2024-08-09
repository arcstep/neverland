defmodule Neverland.Project.Resource do
  # 项目文件夹的配置
  @project_base_path Application.compile_env!(:neverland, __MODULE__)[:textlong_root]

  # 获取项目文件列表
  def file_list(project_id \\ "") do
    project_path = project_path(project_id)
    {:ok, files} = File.ls(project_path)

    files
    |> Enum.filter(&filter_files/1)
    |> Enum.map(fn file ->
      full_path = Path.join(project_path, file)

      %{
        type: if(File.dir?(full_path), do: "dir", else: "file"),
        name: file,
        path: full_path,
        id: UUID.uuid5(:dns, full_path)
      }
    end)
  end

  defp filter_files(file_name) do
    excluded_files = ["project_config.yml", "project_list.yml", "__LOG__"]
    not Enum.member?(excluded_files, file_name)
  end

  # 创建文件
  def create_file(project_id, file_name) do
    path = Path.join(project_path(project_id), file_name)
    File.touch(path)
  end

  # 删除文件
  def delete_file(project_id, file_name) do
    path = Path.join(project_path(project_id), file_name)
    File.rm(path)
  end

  # 重命名文件
  def rename_file(project_id, old_name, new_name) do
    old_path = Path.join(project_path(project_id), old_name)
    new_path = Path.join(project_path(project_id), new_name)
    File.rename(old_path, new_path)
  end

  # 查看文件内容
  def read_file(project_id, file_name) do
    path = Path.join(project_path(project_id), file_name)
    File.read(path)
  end

  # 获取项目路径
  defp project_path(project_id) do
    Path.join(@project_base_path, project_id)
  end
end
