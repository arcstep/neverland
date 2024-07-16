defmodule Neverland.Sandbox do

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

  def handle_info(_port, data, %{cur_reply_to: reply_to} = state) do
    # IO.puts(inspect(port))
    # IO.puts(inspect(data))
    {event, processed_data} =
      case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
        nil -> {"text", data}
        [event, matched_data] -> {event, matched_data}
      end

    # 处理和转发来自标准IO的消息
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

    {:noreply, state}
  end

  def handle_info(_port, data, state) do
    IO.puts("Received data without a current reply_to: #{data}")
    # 可以在这里添加处理逻辑，或者简单地忽略这个消息
    {:noreply, state}
  end

end
