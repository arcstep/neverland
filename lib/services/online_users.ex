defmodule Neverland.OnlineUsers do
  use GenServer

  # 启动GenServer
  def start_link(opts \\ []) do
    name = opts |> Keyword.get(:name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, Keyword.put_new(opts, :name, name))
  end

  # 添加在线用户
  @spec add_online_user(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any()) :: :ok
  def add_online_user(pid, user_type) do
    GenServer.cast(pid, {:add_online, user_type})
  end

  # 移除在线用户
  def remove_online_user(pid, user_type) do
    GenServer.cast(pid, {:remove_online, user_type})
  end

  # 获取在线用户列表
  def get_online_users(pid) do
    GenServer.call(pid, :get_online_users)
  end

  # GenServer回调
  def init(_) do
    {:ok, %{humans: [], ghosts: []}}
  end

  def handle_cast({:add_online, {:human, user_id}}, state) do
    {:noreply, update_online_list(state, :humans, user_id, :add)}
  end

  def handle_cast({:add_online, {:ghost, ghost_id}}, state) do
    {:noreply, update_online_list(state, :ghosts, ghost_id, :add)}
  end

  def handle_cast({:remove_online, {:human, user_id}}, state) do
    {:noreply, update_online_list(state, :humans, user_id, :remove)}
  end

  def handle_cast({:remove_online, {:ghost, ghost_id}}, state) do
    {:noreply, update_online_list(state, :ghosts, ghost_id, :remove)}
  end

  def handle_call(:get_online_users, _from, state) do
    {:reply, state, state}
  end

  defp update_online_list(state, type, id, action) do
    list = Map.get(state, type)
    updated_list =
      case action do
        :add -> List.insert_at(list, -1, id)
        :remove -> List.delete(list, id)
      end
    Map.put(state, type, updated_list)
  end
end
