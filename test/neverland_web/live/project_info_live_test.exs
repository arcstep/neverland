defmodule NeverlandWeb.InfoLiveTest do
  use NeverlandWeb.ConnCase

  import Phoenix.LiveViewTest
  import Neverland.ProjectFixtures

  @create_attrs %{id: "some id", owner: "some owner", public: true, state: "some state", description: "some description", created_at: "2024-07-28T03:13:00Z", updated_at: "2024-07-28T03:13:00Z"}
  @update_attrs %{id: "some updated id", owner: "some updated owner", public: false, state: "some updated state", description: "some updated description", created_at: "2024-07-29T03:13:00Z", updated_at: "2024-07-29T03:13:00Z"}
  @invalid_attrs %{id: nil, owner: nil, public: false, state: nil, description: nil, created_at: nil, updated_at: nil}

  defp create_info(_) do
    info = info_fixture()
    %{info: info}
  end

  describe "Index" do
    setup [:create_info]

    test "lists all infos", %{conn: conn, info: info} do
      {:ok, _index_live, html} = live(conn, ~p"/infos")

      assert html =~ "Listing Infos"
      assert html =~ info.id
    end

    test "saves new info", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/infos")

      assert index_live |> element("a", "New Info") |> render_click() =~
               "New Info"

      assert_patch(index_live, ~p"/infos/new")

      assert index_live
             |> form("#info-form", info: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#info-form", info: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/infos")

      html = render(index_live)
      assert html =~ "Info created successfully"
      assert html =~ "some id"
    end

    test "updates info in listing", %{conn: conn, info: info} do
      {:ok, index_live, _html} = live(conn, ~p"/infos")

      assert index_live |> element("#infos-#{info.id} a", "Edit") |> render_click() =~
               "Edit Info"

      assert_patch(index_live, ~p"/infos/#{info}/edit")

      assert index_live
             |> form("#info-form", info: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#info-form", info: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/infos")

      html = render(index_live)
      assert html =~ "Info updated successfully"
      assert html =~ "some updated id"
    end

    test "deletes info in listing", %{conn: conn, info: info} do
      {:ok, index_live, _html} = live(conn, ~p"/infos")

      assert index_live |> element("#infos-#{info.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#infos-#{info.id}")
    end
  end

  describe "Show" do
    setup [:create_info]

    test "displays info", %{conn: conn, info: info} do
      {:ok, _show_live, html} = live(conn, ~p"/infos/#{info}")

      assert html =~ "Show Info"
      assert html =~ info.id
    end

    test "updates info within modal", %{conn: conn, info: info} do
      {:ok, show_live, _html} = live(conn, ~p"/infos/#{info}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Info"

      assert_patch(show_live, ~p"/infos/#{info}/show/edit")

      assert show_live
             |> form("#info-form", info: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#info-form", info: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/infos/#{info}")

      html = render(show_live)
      assert html =~ "Info updated successfully"
      assert html =~ "some updated id"
    end
  end
end
