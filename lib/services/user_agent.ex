defmodule Neverland.UserAgent do
  use GenServer

  # 启动用户代理的函数
  def start_link(user_id) do
    GenServer.start_link(__MODULE__, %{user_id: user_id, online: false, mailbox: []}, name: via_tuple(user_id))
  end

  # 通过用户ID查询用户状态
  def get_status(user_id) do
    GenServer.call(via_tuple(user_id), :get_status)
  end

  # 发送消息给特定用户
  def send_message(user_id, message) do
    GenServer.cast(via_tuple(user_id), {:send_message, message})
  end

  # GenServer回调
  def init(state) do
    {:ok, Map.put(state, :online, true)}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send_message, message}, state) do
    new_mailbox = [message | state.mailbox]
    {:noreply, Map.put(state, :mailbox, new_mailbox)}
  end

  # 使用用户ID构造一个唯一的GenServer名称
  defp via_tuple(user_id) do
    {:via, Registry, {Neverland.Registry, "user_agent_#{user_id}"}}
  end
end
