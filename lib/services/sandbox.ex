defmodule Neverland.Sandbox do
  def process_data(data) do
    case Regex.run(~r/>-\[(.*?)\]>>(.*)/, data, capture: :all_but_first) do
      nil -> {"text", data}
      [event, matched_data] -> {event, matched_data}
    end
  end

  def process_event(event, processed_data, thread_id, reply_to \\ nil, current_output \\ "") do
    if reply_to do
      send(reply_to, {:thread_id, thread_id, :event, event, :output, processed_data})
    end
    case String.downcase(event) do
      "text" ->
        IO.write(processed_data)
        current_output <> processed_data
      "chunk" ->
        IO.write(processed_data)
        current_output <> processed_data
      "final" ->
        IO.puts("\n" <> processed_data)
        current_output
      "info" ->
        IO.puts(processed_data)
        current_output
      "end" ->
        send(reply_to, {:thread_id, thread_id, :event, "output", :output, current_output})
      _ ->
        current_output
    end
  end

end
