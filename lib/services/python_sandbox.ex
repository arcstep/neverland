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

  def run_script(pid, script_name, reply \\ nil, thread_id \\ nil) do
    GenServer.call(pid, {:run_script, script_name, :reply, reply, :thread_id, thread_id})
  end

  def handle_call({:run_script, script_name, :reply, reply, :thread_id, thread_id}, _from, %{scripts_dir: scripts_dir, batches: batches} = state) do
    python_script_path = Path.join([scripts_dir, script_name])
    port = Port.open({:spawn, "python3 -u #{python_script_path}"}, [:binary, :exit_status])

    cur_thread_id = case thread_id do
      nil -> :erlang.unique_integer([:positive])
      _ -> thread_id
    end

    # 使用Port引用作为键，存储caller信息
    new_batches = Map.put(batches, port, %{
      caller: reply,
      thread_id: cur_thread_id,
      output: "",
      logs: []
    })

    # 更新state，包括新的batches映射
    new_state = Map.put(state, :batches, new_batches)

    {:reply, {:thread_id, cur_thread_id}, new_state}
  end

  def handle_info({port, {:data, data}}, %{batches: batches} = state) do
    case Map.get(batches, port) do
      nil ->
        {:noreply, state}
      %{caller: _caller, output: current_output, logs: current_logs} = batch ->
        {event, processed_data} =
          case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
            nil -> {"text", data}
            [event, matched_data] -> {event, matched_data}
          end

        new_logs = [{event, processed_data} | current_logs]
        new_output =
          case event do
            "text" ->
              IO.puts(processed_data)
              current_output <> processed_data
            "final" ->
              IO.puts("\n" <> processed_data)
              current_output <> processed_data
            "chunk" ->
              IO.write(processed_data)
              current_output
            "info" ->
              IO.puts(processed_data)
              current_output
            _ ->
              current_output
          end

        # 更新该批次的信息
        new_batch = batch |> Map.put(:output, new_output) |> Map.put(:logs, new_logs)
        new_batches = Map.put(batches, port, new_batch)
        new_state = Map.put(state, :batches, new_batches)

        {:noreply, new_state}
    end
  end

  def handle_info({port, {:exit_status, status}}, %{batches: batches} = state) do
    IO.puts("\nPython script exited with status: #{status}")
    # IO.puts(inspect(state))
    case Map.get(batches, port) do
      %{caller: caller, thread_id: thread_id, output: output} when not is_nil(caller) and output != "" ->
        IO.puts("sending final output to " <> inspect(caller))
        send(caller, {:output, output, :thread_id, thread_id})
      _ ->
        IO.puts("Empty Caller.")
    end

    {:stop, :normal, state}
  end

end
