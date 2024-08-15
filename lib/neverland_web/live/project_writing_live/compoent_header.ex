defmodule NeverlandWeb.Project.WritingLive.Component.Header do
  use NeverlandWeb, :live_component

  # alias Neverland.Project 

  @impl true
  def render(assigns) do
    ~H"""
    <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
      <div style="flex-grow: 1;">
        <%= @info.title %>
        <span style="color: gray; font-size: small;">
          由 <%= @info.owner %> 更新于 <%= Timex.format!(
            @info.updated_at,
            "{YYYY}-{0M}-{0D} {h24}:{0m}:{0s}"
          ) %>
        </span>
      </div>
      <div style="display: flex; align-items: center;">
        <label style="margin-right: 10px;">
          <input
            type="radio"
            name="command"
            value="edit"
            phx-click="update_header_choose_command"
            checked={if @command == "edit", do: true, else: false}
          /> 编辑
        </label>
        <label style="margin-right: 10px;">
          <input
            type="radio"
            name="command"
            value="idea"
            phx-click="update_header_choose_command"
            checked={if @command == "idea", do: true, else: false}
          /> 创意
        </label>
        <label style="margin-right: 10px;">
          <input
            type="radio"
            name="command"
            value="outline"
            phx-click="update_header_choose_command"
            checked={if @command == "outline", do: true, else: false}
          /> 提纲
        </label>
        <label style="margin-right: 10px;">
          <input
            type="radio"
            name="command"
            value="from_outline"
            phx-click="update_header_choose_command"
            checked={if @command == "from_outline", do: true, else: false}
          /> 扩写
        </label>
      </div>
    </div>
    """
  end
end
