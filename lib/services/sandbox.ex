defmodule Neverland.Sandbox do
  def process_data(data) do
    case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
      nil -> {"text", data}
      [event, matched_data] -> {event, matched_data}
    end
  end

  def process_event(event, processed_data, thread_id, reply_to \\ nil) do
    if reply_to do
      send(reply_to, {:thread_id, thread_id, :event, event, :output, processed_data})
    end

    case String.downcase(event) do
      "text" ->
        IO.write(processed_data)

      "chunk" ->
        IO.write(processed_data)

      "final" ->
        IO.puts("\n" <> processed_data)

      "info" ->
        IO.puts(processed_data)

      "end" ->
        IO.puts("\n")

      _ ->
        nil
    end
  end

  @doc """
  从Python文件中提取示例之前的所有代码
  """
  def fetch_code_and_save(paths_parts) do
    path = Enum.join(paths_parts, "/")

    script_content = File.read!(path)
    repl_code = File.read!("priv/scripts/__repl__.py")
    full_code = "#{script_content}\n\n#{repl_code}"

    string_without_py =
      case String.ends_with?(path, ".py") do
        true -> String.trim_trailing(path, ".py")
        false -> path
      end

    new_file_path = "#{string_without_py}__repl__.py"
    File.write!(new_file_path, full_code)
    new_file_path
  end
end
