defmodule Neverland.Sandbox do
  def invoke_command(%{port: port, queue: queue} = state) do
    case queue do
      [] ->
        state
      [head | queue_rest] ->
        case head do
          {:input, in_text, :reply_to, reply_to} ->
            data = {self(), {:command, "#{in_text}\n"}}
            IO.puts(inspect(data))
            send(port, data)
            state
              |> Map.put(:queue, queue_rest)
              |> Map.put(:cur_reply_to, reply_to)
        end
    end
  end

  def process_data(data) do
    case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
      nil -> {"text", data}
      [event, matched_data] -> {event, matched_data}
    end
  end

  def process_event(event, processed_data, state, reply_to \\ nil, current_output \\ "") do
    if reply_to do
      send(reply_to, {event, processed_data})
    end
    case event do
      "end" ->
        invoke_command(state)
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
  end

end
