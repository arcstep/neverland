defmodule Neverland.PythonSandbox do
  use GenServer

  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    scripts_dir = opts |> Keyword.get(:scripts_dir, "./priv/scripts")
    GenServer.start_link(__MODULE__, %{scripts_dir: scripts_dir, buffer: "", port: nil}, Keyword.put_new(opts, :name, name))
  end

  def init(state) do
    # 确保在初始状态中包含batches键，初始值为空映射
    new_state = Map.put_new(state, :batches, %{})
    {:ok, new_state}
  end

  def run_script(pid, script_name) do
    GenServer.call(pid, {:run_script, script_name})
  end

  def handle_call({:run_script, script_name}, from, %{scripts_dir: scripts_dir, batches: batches} = state) do
    python_script_path = Path.join([scripts_dir, script_name])
    port = Port.open({:spawn, "python3 -u #{python_script_path}"}, [:binary, :exit_status])

    # 使用Port引用作为键，存储caller信息
    new_batches = Map.put(batches, port, %{caller: from, output: "", logs: []})

    # 更新state，包括新的batches映射
    new_state = Map.put(state, :batches, new_batches)

    {:reply, :ok, new_state}
  end

  def handle_info({port, {:data, data}}, %{batches: batches} = state) do
    # IO.puts(">>>>>>>>>>>")
    # IO.puts(inspect(state))
    # IO.puts(inspect(port))
    # IO.puts(data)
    # IO.puts(">>>>>>>>>>>")
    case Map.get(batches, port) do
      nil ->
        {:noreply, state}
      %{caller: _caller, output: current_output, logs: current_logs} = batch ->
        case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
          nil ->
            # 如果没有匹配到数据，可以选择忽略或者以不同的方式处理
            # IO.puts(">>>>")
            # IO.puts(data)
            # IO.puts("<<<<")
            {:noreply, state}
          [event, data] ->
            # 将事件和数据作为元组添加到logs中
            new_logs = [{event, data} | current_logs]

            # 如果事件类型是text或final，则将数据追加到output中
            # IO.puts(">-[#{event}]>>")
            new_output =
              case event do
                "text" ->
                  IO.puts(data)
                  current_output <> data
                "final" ->
                  IO.puts("\n" <> data)
                  current_output <> data
                _ ->
                  IO.write(data)
                  current_output
              end

            # 更新该批次的信息
            new_batch = Map.put(batch, :output, new_output)
            new_batch = Map.put(new_batch, :logs, new_logs)
            new_batches = Map.put(batches, port, new_batch)

            # 更新state
            new_state = Map.put(state, :batches, new_batches)

            {:noreply, new_state}
        end
    end
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    IO.puts("\nPython script exited with status: #{status}")
    IO.puts(inspect(state))
    {:stop, :normal, state}
  end

end
