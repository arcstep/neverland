defmodule NeverlandWeb.TextReviewLive do
  use NeverlandWeb, :live_view

  alias Neverland.Content
  # alias Neverland.Content.TextReview

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <.header class="text-center">
        文本内容审核
      </.header>

      <div class="text-center mb-4">
        待审核（<%= @pending_count %>）｜已审核（<%= @reviewed_count %>）
      </div>

      <table class="min-w-full divide-y divide-gray-200">
        <thead>
          <tr>
            <th>来源</th>
            <th>拥有者</th>
            <th>提交时间</th>
            <th>内容</th>
            <th>审核结果</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <%= for review <- @reviews do %>
            <tr>
              <td><%= review.source %></td>
              <td><%= review.owner %></td>
              <td><%= review.submitted_at %></td>
              <td><%= review.content %></td>
              <td>
                <%= if review.risk do %>
                  <span class="text-red-500">有风险</span>
                  <ul>
                    <%= for tag <- review.tags do %>
                      <li><%= tag %></li>
                    <% end %>
                  </ul>
                <% else %>
                  <span class="text-green-500">无风险</span>
                <% end %>
              </td>
              <td>
                <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                  修改
                </button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    reviews = Content.list_text_reviews()
    pending_count = Enum.count(reviews, fn review -> !review.risk end)
    reviewed_count = Enum.count(reviews, fn review -> review.risk end)

    {:ok,
     assign(socket,
       reviews: reviews,
       pending_count: pending_count,
       reviewed_count: reviewed_count
     )}
  end
end
