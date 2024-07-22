defmodule Neverland.SandboxPython do
  use GenServer
  alias Neverland.Sandbox

  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    scripts_dir = opts |> Keyword.get(:scripts_dir, "./priv/scripts")
    GenServer.start_link(__MODULE__, %{scripts_dir: scripts_dir}, Keyword.put_new(opts, :name, name))
  end

  def init(state) do
    # 确保在初始状态中包含batches键，初始值为空映射
    new_state = Map.put_new(state, :batches, %{})
    {:ok, new_state}
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  - script_name 表示所调用脚本，支持参数化
  - reply_to 代表一个调用者
  - thread_id 代表一次调用，即调用者发起过多次平行调用
  """
  def invoke(pid, script_name, reply_to \\ nil, thread_id \\ nil) do
    GenServer.call(pid, {:invoke, script_name, :reply_to, reply_to, :thread_id, thread_id})
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:invoke, script_name, :reply_to, reply_to, :thread_id, thread_id}, _from, state) do
    python_script_path = Path.join([state.scripts_dir, script_name])
    # 为每个脚本创建独立的Port
    port = Port.open(
      {:spawn, "python3 -u #{python_script_path}"},
      [:binary, :exit_status]
    )

    cur_thread_id = case thread_id do
      nil -> :erlang.unique_integer([:positive])
      _ -> thread_id
    end

    # 存储Port和相关信息，确保独立通信
    new_batches = Map.put(state.batches, port, %{
      reply_to: reply_to,
      thread_id: cur_thread_id,
      output: "",
      logs: []
    })
    new_state = Map.put(state, :batches, new_batches)

    {:reply, {:ok, cur_thread_id}, new_state}
  end

  def handle_info({port, {:data, data}}, %{batches: batches} = state) do
    IO.puts(inspect(port))
    case Map.get(batches, port) do
      nil ->
        {:noreply, state}

      %{reply_to: reply_to, thread_id: thread_id, output: current_output, logs: current_logs} = batch ->
        {event, processed_data} = Sandbox.process_data(data)

        new_logs = [{event, processed_data} | current_logs]
        new_output = Sandbox.process_event(event, processed_data, thread_id, reply_to, current_output)

        # 更新该批次的信息
        new_batch = batch |> Map.put(:output, new_output) |> Map.put(:logs, new_logs)
        new_batches = Map.put(batches, port, new_batch)
        new_state = Map.put(state, :batches, new_batches)

        {:noreply, new_state}
    end
  end

  def handle_info({port, {:exit_status, status}}, %{batches: batches} = state) do
    IO.puts("\nPython script exited with status: #{status} | " <> inspect(port))
    new_batches = Map.delete(batches, port)
    new_state = Map.put(state, :batches, new_batches)

    {:noreply, new_state}
  end

end
