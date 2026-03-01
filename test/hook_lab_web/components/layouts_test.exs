defmodule HookLabWeb.LayoutsTest do
  use HookLabWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias HookLabWeb.Layouts

  describe "theme_toggle/1" do
    test "renders three theme buttons dispatching correct theme values" do
      html = render_component(&Layouts.theme_toggle/1, %{})

      assert html =~ "phx:set-theme"
      assert html =~ "system"
      assert html =~ "winter"
      assert html =~ "dark"
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
