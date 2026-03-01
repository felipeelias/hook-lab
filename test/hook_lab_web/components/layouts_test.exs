defmodule HookLabWeb.LayoutsTest do
  use HookLabWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias HookLabWeb.Layouts

  describe "theme_toggle/1" do
    test "renders three buttons with correct data-phx-theme values" do
      html = render_component(&Layouts.theme_toggle/1, %{})

      assert html =~ ~s(data-phx-theme="system")
      assert html =~ ~s(data-phx-theme="winter")
      assert html =~ ~s(data-phx-theme="dark")
    end
  end

  describe "flash_group/1" do
    test "renders info flash message" do
      html = render_component(&Layouts.flash_group/1, %{flash: %{"info" => "Info message"}})
      assert html =~ "Info message"
    end

    test "renders error flash message" do
      html = render_component(&Layouts.flash_group/1, %{flash: %{"error" => "Error occurred"}})
      assert html =~ "Error occurred"
    end

    test "renders client-error and server-error sections" do
      html = render_component(&Layouts.flash_group/1, %{flash: %{}})
      assert html =~ "client-error"
      assert html =~ "server-error"
    end
  end
end
