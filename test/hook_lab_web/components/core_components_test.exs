defmodule HookLabWeb.CoreComponentsTest do
  use HookLabWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias HookLabWeb.CoreComponents

  describe "flash/1" do
    test "renders info flash" do
      html =
        render_component(&CoreComponents.flash/1, %{kind: :info, flash: %{"info" => "Hello"}})

      assert html =~ "Hello"
      assert html =~ "alert-info"
    end

    test "renders error flash" do
      html =
        render_component(&CoreComponents.flash/1, %{kind: :error, flash: %{"error" => "Oops"}})

      assert html =~ "Oops"
      assert html =~ "alert-error"
    end

    test "does not render when no flash message" do
      html = render_component(&CoreComponents.flash/1, %{kind: :info, flash: %{}})
      refute html =~ "alert-info"
    end
  end

  describe "icon/1" do
    test "renders hero icon span" do
      html = render_component(&CoreComponents.icon/1, %{name: "hero-x-mark"})
      assert html =~ "hero-x-mark"
    end

    test "renders with custom class" do
      html = render_component(&CoreComponents.icon/1, %{name: "hero-arrow-path", class: "size-6"})
      assert html =~ "hero-arrow-path"
      assert html =~ "size-6"
    end
  end
end
