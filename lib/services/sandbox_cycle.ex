defmodule Neverland.SandboxCycle do
  use GenServer
  alias Neverland.Sandbox

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  @doc """
  启动一个命令行。
  支持标准输入和标准输出。
  """
  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    # default_path = "/Users/xuehongwei/.pyenv/versions/3.10.9/bin/python"
    default_cmd = "python3 -u ./priv/scripts/cycle.py"
    command = opts |> Keyword.get(:command,  default_cmd)
    GenServer.start_link(
      __MODULE__,
      %{command: command},
      Keyword.put_new(opts, :name, name)
    )
  end

  def init(%{command: command} = state) do
    port = Port.open({:spawn, command}, [:binary, :exit_status])
    new_state = state
      |> Map.put(:queue, [])
      |> Map.put(:port, port)
    {:ok, new_state}
  end

  @spec invoke(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  @doc """
  通过标准输入调用指令。
  """
  def invoke(pid, in_text \\ "", reply_to \\ nil) do
    GenServer.call(pid, {:input, in_text, :reply_to, reply_to})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:input, _in_text, :reply_to, _reply_to}=msg, _from, %{queue: queue} = state) do
    new_queue = queue ++ [msg]
    new_state = Map.put(state, :queue, new_queue)
    {:reply, :ok, Sandbox.invoke_command(new_state)}
  end

  def handle_info({port, {:exit_status, status}}, state) when is_port(port) do
    IO.puts("\Command exited with status: #{status} | " <> inspect(port))
    {:stop, :normal, state}
  end

  def handle_info({port, {:data, data}}, state) when is_port(port) do
    Sandbox.handle_info(port, data, state)
  end

end
