defmodule PythonInteraction do
  def start_link do
    # 启动Python脚本
    port = Port.open({:spawn, "python3 -u priv/scripts/cycle.py"}, [:binary, :exit_status, :in, :out])
    {:ok, port}
  end

  def run_script(input_data) do
    # 打开端口
    {:ok, port} = start_link()

    # 向Python脚本发送输入数据
    send(port, {self(), {:command, input_data <> "\n"}})

    # 接收Python脚本的输出
    receive do
      {_port, :closed} ->
        IO.puts("Closed.")
      {_port, {:data, data}} ->
        IO.puts("Received from Python: " <> to_string(data))
    end
  end

end

# 启动模块
# {:ok, _} = PythonInteraction.start_link()

# 运行脚本并发送输入数据
# PythonInteraction.run_script("Hello from Elixir")
