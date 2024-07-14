defmodule Neverland.Plugin do
  use GenServer

  @doc """
  启动一个命令行。
  支持标准输入和标准输出。
  """
  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    command = opts |> Keyword.get(:command,  "python3 -u ./priv/scripts/cycle.py")
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

  def invoke_command(%{port: port, queue: queue} = state) do
    [head|_queue_rest] = queue
    case head do
      {:input, in_text, :reply_to, reply_to} ->
        data = {self(), {:command, in_text}}
        # IO.puts(inspect(data))
        send(port, data)
        state
          |> Map.put(:queue, queue)
          |> Map.put(:cur_reply_to, reply_to)
      _ ->
        state |> Map.put(:cur_reply_to, nil)
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:input, _in_text, :reply_to, _reply_to}=msg, _from, %{queue: queue} = state) do
    new_queue = queue ++ [msg]
    new_state = Map.put(state, :queue, new_queue)
    {:reply, :ok, invoke_command(new_state)}
  end

  def handle_info({port, {:data, data}}, %{cur_reply_to: reply_to} = state) do
    IO.puts(inspect(port))
    IO.puts(inspect(data))
    {event, processed_data} =
      case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
        nil -> {"text", data}
        [event, matched_data] -> {event, matched_data}
      end

    send(reply_to, {event, processed_data})
    case event do
      "text" ->
        IO.puts(processed_data)
      "final" ->
        IO.puts("\n" <> processed_data)
      "chunk" ->
        IO.write(processed_data)
      "info" ->
        IO.puts(processed_data)
    end

    case event do
      # "end" ->
      #   {:noreply, invoke_command(state)}
      _ ->
        {:noreply, state}
    end
  end

  def handle_info({_port, {:data, data}}, state) do
    IO.puts("Received data without a current reply_to: #{data}")
    # 可以在这里添加处理逻辑，或者简单地忽略这个消息
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, status}}, state) do
    IO.puts("\Command exited with status: #{status} | " <> inspect(port))
    {:stop, :normal, state}
  end

end
