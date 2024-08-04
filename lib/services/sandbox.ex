defmodule Neverland.Sandbox do
  def process_data(data) do
    case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
      nil -> {"text", data}
      [event, matched_data] -> {event, matched_data}
    end
  end

  @doc """
  处理来自 Python 脚本的输出，并将结果发送给 LiveView 组件
  例如：类似这样的processed_data，应当自动将其中的 \e[34m和\e[0m 过滤掉
        "\e[34m\n>->>> Prompt ID: IDEA | output.md <<<-<\n\e[0m"
        "\e[32m冬\e[0m"
        "\e[32m日\e[0m"
        "\e[32m里\e[0m"
        "\e[32m，\e[0m"
      变为：
        "\n>->>> Prompt ID: IDEA | output.md <<<-<\n"
        "冬"
        "日"
        "里"
        "，"

  """
  def process_event(event, processed_data, thread_id, reply_to \\ nil) do
    # 移除 ANSI 逃逸序列
    no_ansi_processed_data = remove_ansi_escape_codes(processed_data)

    # 如果有回复地址，则发送数据
    if reply_to do
      send(reply_to, {:thread_id, thread_id, :event, event, :output, no_ansi_processed_data})
    end

    # 根据事件类型处理输出
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

  # 移除 ANSI 逃逸序列的辅助函数
  defp remove_ansi_escape_codes(data) do
    data
    |> String.replace(~r/\e\[[0-9;]*m/, "")
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
