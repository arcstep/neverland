defmodule Neverland.PythonSandbox do
  use GenServer

  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    scripts_dir = opts |> Keyword.get(:scripts_dir, "/Users/xuehongwei/github/neverland/priv/scripts")
    GenServer.start_link(__MODULE__, %{scripts_dir: scripts_dir, buffer: "", port: nil}, Keyword.put_new(opts, :name, name))
  end

  @spec init(map()) :: {:ok, map()}
  def init(state) do
    {:ok, state}
  end

  def run_script(pid, script_name) do
    GenServer.call(pid, {:run_script, script_name})
  end

  def handle_call({:run_script, script_name}, _from, %{scripts_dir: scripts_dir} = state) do
    python_script_path = Path.join([scripts_dir, script_name])
    port = Port.open({:spawn, "python3 #{python_script_path}"}, [:binary, :exit_status])
    {:reply, :ok, %{state | port: port}}
  end

  def handle_info({_port, {:data, data}}, %{buffer: buffer} = state) do
    new_buffer = buffer <> data
    {events, new_buffer} = parse_events(new_buffer)
    Enum.each(events, &handle_event/1)
    {:noreply, %{state | buffer: new_buffer}}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    IO.puts("Python script exited with status: #{status}")
    {:stop, :normal, state}
  end

  @spec handle_event(binary()) :: :ok
  def handle_event(event) do
    [event_name, data] = String.split(event, "]>> ", parts: 2)
    IO.puts("Event: #{event_name}, Data: #{data}")
  end

  def parse_events(buffer) do
    split_buffer = String.split(buffer, "\n", trim: true)
    Enum.reduce(split_buffer, {[], ""}, fn line, {events, buffer} ->
      if String.starts_with?(line, ">-[") do
        if buffer != "", do: {events ++ [buffer], line}, else: {events, line}
      else
        {events, buffer <> "\n" <> line}
      end
    end)
  end
end
