defmodule Neverland.SandboxPython do
  use GenServer
  alias Neverland.Sandbox

  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    scripts_dir = opts |> Keyword.get(:scripts_dir, "./priv/scripts")

    GenServer.start_link(
      __MODULE__,
      %{scripts_dir: scripts_dir},
      Keyword.put_new(opts, :name, name)
    )
  end

  def init(state) do
    # 确保在初始状态中包含batches键，初始值为空映射
    new_state = Map.put_new(state, :batches, %{})
    {:ok, new_state}
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def is_thread_exist(pid, thread_id) do
    GenServer.call(pid, {:is_thread_exist, thread_id})
  end

  @doc """
  - script_name 表示所调用脚本，支持参数化
  - reply_to 代表一个调用者
  -  代表一次调用，即调用者发起过多次平行调用
  """
  def run(pid, script_name, reply_to \\ nil, thread_id \\ nil) do
    GenServer.call(pid, {:run_script, script_name, :reply_to, reply_to, :thread_id, thread_id})
  end

  def input(pid, input, thread_id) do
    GenServer.call(pid, {:input, input, :thread_id, thread_id})
  end

  def exit_all_scripts(pid) do
    IO.puts("closing all Python ports...")

    state = get_state(pid)

    state.batches
    |> Enum.each(fn {port, %{thread_id: thread_id}} ->
      IO.puts("closing port: #{inspect(port)}, thread_id: #{inspect(thread_id)}")
      send(port, {pid, {:command, "exit\n"}})
      Process.sleep(100)
      send(port, {self(), :close})
    end)
  end

  def find_batch(batches, thread_id) do
    case Enum.filter(batches, fn {_port, details} -> details.thread_id == thread_id end) do
      [head | _] -> head
      [] -> {:error, "No matching batch found"}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:input, input, :thread_id, thread_id}, _from, %{batches: batches} = state) do
    case find_batch(batches, thread_id) do
      {:error, info} ->
        {:reply, {:error, info}, state}

      {port, _} ->
        send(port, {self(), {:command, input <> "\n"}})
        {:reply, {:ok, thread_id}, state}
    end
  end

  def handle_call(
        {:run_script, script_name, :reply_to, reply_to, :thread_id, thread_id},
        _from,
        %{batches: batches} = state
      ) do
    port =
      case find_batch(batches, thread_id) do
        {:error, _} ->
          code_to_run = Sandbox.fetch_code_and_save([state.scripts_dir, script_name])
          create_script(code_to_run)

        {port, _} ->
          port
      end

    cur_thread_id =
      case thread_id do
        nil -> :erlang.unique_integer([:positive])
        _ -> thread_id
      end

    new_batches =
      Map.put(batches, port, %{
        reply_to: reply_to,
        thread_id: cur_thread_id,
        run_script: script_name
      })

    new_state = Map.put(state, :batches, new_batches)

    {:reply, {:ok, cur_thread_id}, new_state}
  end

  defp create_script(code_to_run) do
    Port.open(
      {:spawn, "python3 -u '#{code_to_run}'"},
      [:binary, :exit_status]
    )
  end

  def handle_info({port, {:data, data}}, %{batches: batches} = state) do
    case Map.get(batches, port) do
      nil ->
        {:noreply, state}

      %{reply_to: reply_to, thread_id: thread_id} ->
        {event, processed_data} = Sandbox.process_data(data)

        Sandbox.process_event(event, processed_data, thread_id, reply_to)

        {:noreply, state}
    end
  end

  def handle_info({port, {:exit_status, status}}, %{batches: batches} = state) do
    IO.puts("\nPython script exited with status: #{status} | " <> inspect(port))
    new_batches = Map.delete(batches, port)
    new_state = Map.put(state, :batches, new_batches)

    {:noreply, new_state}
  end

  # 在 GenServer 终止时清理所有 Python 进程
  def terminate(reason, _state) do
    IO.puts("Process #{inspect(self())} is being terminated because: #{inspect(reason)}")
    exit_all_scripts(self())
    :ok
  end
end
