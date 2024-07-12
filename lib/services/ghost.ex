defmodule Neverland.Ghost do
  use GenServer

  # Public API

  # 修改start_link以接受:name选项
  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, Keyword.put_new(opts, :name, name))
  end

  # 修改ask_question以接受实例名
  def ask_question(name, question) do
    GenServer.call(name, {:ask_question, question})
  end

  # GenServer Callbacks

  def init(initial_state) do
    {:ok, initial_state}
  end

  def handle_call({:ask_question, question}, _from, state) do
    answer = "这是对‘#{question}’的回答。" # 这里可以实现更复杂的逻辑
    {:reply, answer, state}
  end
end
