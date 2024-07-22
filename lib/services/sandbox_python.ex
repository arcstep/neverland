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

  @doc """
  - script_name 表示所调用脚本，支持参数化
  - reply_to 代表一个调用者
  - thread_id 代表一次调用，即调用者发起过多次平行调用
  """
  def run(pid, script_name, reply_to \\ nil, thread_id \\ nil) do
    GenServer.call(pid, {:run_script, script_name, :reply_to, reply_to, :thread_id, thread_id})
  end

  def input(pid, input, thread_id) do
    GenServer.call(pid, {:input, input, :thread_id, thread_id})
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
      {:error, _} ->
        {:reply, {:error, "No matching batch found"}, state}

      {port, _} ->
        send(port, {self(), {:command, input <> "\n"}})
        {:reply, {:ok, thread_id}, state}
    end
  end

  def handle_call(
        {:run_script, script_name, :reply_to, reply_to, :thread_id, thread_id},
        _from,
        state
      ) do
    code_to_run = Sandbox.fetch_code_and_save([state.scripts_dir, script_name])

    port =
      Port.open(
        {:spawn, "python3 -u '#{code_to_run}'"},
        [:binary, :exit_status]
      )

    cur_thread_id =
      case thread_id do
        nil -> :erlang.unique_integer([:positive])
        _ -> thread_id
      end

    new_batches =
      Map.put(state.batches, port, %{
        reply_to: reply_to,
        thread_id: cur_thread_id,
        run_script: script_name
      })

    new_state = Map.put(state, :batches, new_batches)

    {:reply, {:ok, cur_thread_id}, new_state}
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
end
