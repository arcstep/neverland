defmodule Neverland.SandboxCycle do
  @moduledoc """
  `Neverland.SandboxCycle` 模块用于启动和管理一个循环模式的命令行进程。
  该进程支持标准输入和标准输出，允许与外部脚本进行交互。
  """

  use GenServer
  alias Neverland.Sandbox

  @doc """
  启动一个命令行进程。

  ## 参数

    - `opts` - 启动进程时的选项，可以包含:
      - `:name` - 进程的名称。
      - `:command` - 要执行的命令，默认为 `"python3 -u ./priv/scripts/chat.py"`。

  ## 返回值

    - `:ignore` - 如果进程被忽略。
    - `{:error, any()}` - 如果启动过程中发生错误。
    - `{:ok, pid()}` - 如果进程成功启动，返回进程ID。
  """
  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    # default_path = "/Users/xuehongwei/.pyenv/versions/3.10.9/bin/python"
    default_cmd = "python3 -u ./priv/scripts/chat.py"
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

  def handle_info({port, {:exit_status, status}}, state) when is_port(port) when is_port(port) do
    IO.puts("\Command exited with status: #{status} | " <> inspect(port))
    {:stop, :normal, state}
  end

  def handle_info({port, {:data, data}}, %{cur_reply_to: reply_to} = state) when is_port(port) do
    {event, processed_data} = Sandbox.process_data(data)
    Sandbox.process_event(event, processed_data, state, reply_to)

    {:noreply, state}
  end

  def handle_info(_port, data, state) do
    IO.puts(data)
    {:noreply, state}
  end

end
