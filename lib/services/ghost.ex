defmodule Neverland.Ghost do
  @doc """
  - 大模型思考
  - 检索常驻概念图
  - 自动更新常驻概念图
  - 检索知识概念图
  - 补充知识概念图
  - 资料阅读
  - 文档写作
  - 自我训练：基于知识概念图

  """
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
    # 这里可以实现更复杂的逻辑
    answer = "这是对‘#{question}’的回答。"
    {:reply, answer, state}
  end
end
