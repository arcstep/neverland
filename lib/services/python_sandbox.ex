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

  def run_script(pid, script_name, reply \\ nil) do
    GenServer.call(pid, {:run_script, script_name, :reply, reply})
  end

  def handle_call({:run_script, script_name, :reply, reply}, _from, %{scripts_dir: scripts_dir, batches: batches} = state) do
    python_script_path = Path.join([scripts_dir, script_name])
    port = Port.open({:spawn, "python3 -u #{python_script_path}"}, [:binary, :exit_status])

    # 使用Port引用作为键，存储caller信息
    new_batches = Map.put(batches, port, %{caller: reply, output: "", logs: []})

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
            {:noreply, state}
          [event, data] ->
            # 将事件和数据作为元组添加到logs中
            new_logs = [{event, data} | current_logs]

            # 如果事件类型是text或final，则将数据追加到output中
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
            new_batch = batch |> Map.put(:output, new_output) |> Map.put(:logs, new_logs)
            new_batches = Map.put(batches, port, new_batch)
            new_state = Map.put(state, :batches, new_batches)

            {:noreply, new_state}
        end
    end
  end

  def handle_info({port, {:exit_status, status}}, %{batches: batches} = state) do
    IO.puts("\nPython script exited with status: #{status}")
    IO.puts(inspect(port))
    IO.puts(inspect(state))
    case Map.get(batches, port) do
      %{caller: caller, output: output} when not is_nil(caller) and output != "" ->
        IO.puts("sending ...")
        send(caller, {:script_output, output})
      _ ->
        IO.puts("Empty Caller.")
    end

    {:stop, :normal, state}
  end

end
