defmodule HookLabWeb.HookLogLiveTest do
  use HookLabWeb.ConnCase

  import Phoenix.LiveViewTest

  alias HookLab.Hooks

  @valid_attrs %{
    "session_id" => "sess-live-001",
    "hook_event_name" => "PreToolUse",
    "tool_name" => "Bash",
    "tool_input" => %{"command" => "echo hi"},
    "cwd" => "/tmp/project",
    "permission_mode" => "default",
    "model" => "claude-sonnet",
    "raw_payload" => %{"key" => "value"}
  }

  describe "mount" do
    test "renders page with header", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "hook-lab"
    end

    test "streams existing hook logs on mount", %{conn: conn} do
      {:ok, _log} = Hooks.create_hook_log(@valid_attrs)

      {:ok, _view, html} = live(conn, "/")
      assert html =~ "PreToolUse"
      assert html =~ "Bash"
    end
  end

  describe "PubSub" do
    test "new hook log appears via PubSub", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      {:ok, _log} = Hooks.create_hook_log(@valid_attrs)

      html = render(view)
      assert html =~ "PreToolUse"
      assert html =~ "Bash"
    end

    test "new hook log that does not match filters is not streamed", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Apply filter for PostToolUse
      view |> element("form") |> render_change(%{"hook_event_name" => "PostToolUse"})

      # Create a PreToolUse log — should not appear
      {:ok, _log} = Hooks.create_hook_log(@valid_attrs)

      html = render(view)
      refute html =~ "sess-live-001"
    end
  end

  describe "filter event" do
    test "filters displayed logs by hook_event_name", %{conn: conn} do
      {:ok, _log1} = Hooks.create_hook_log(@valid_attrs)

      {:ok, _log2} =
        Hooks.create_hook_log(
          Map.merge(@valid_attrs, %{
            "session_id" => "sess-live-002",
            "hook_event_name" => "PostToolUse"
          })
        )

      {:ok, view, _html} = live(conn, "/")

      html = view |> element("form") |> render_change(%{"hook_event_name" => "PostToolUse"})
      assert html =~ "PostToolUse"
      refute html =~ "sess-live-001"
    end

    test "empty filter value shows all logs", %{conn: conn} do
      {:ok, _log} = Hooks.create_hook_log(@valid_attrs)

      {:ok, view, _html} = live(conn, "/")

      # Filter then clear
      view |> element("form") |> render_change(%{"hook_event_name" => "PostToolUse"})
      html = view |> element("form") |> render_change(%{"hook_event_name" => ""})

      assert html =~ "PreToolUse"
    end
  end

  describe "helpers via rendered output" do
    test "event badge classes are applied", %{conn: conn} do
      {:ok, _log} = Hooks.create_hook_log(@valid_attrs)
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "badge-warning"
    end

    test "long session_id is truncated", %{conn: conn} do
      {:ok, _log} =
        Hooks.create_hook_log(
          Map.put(@valid_attrs, "session_id", "a-very-long-session-id-string")
        )

      {:ok, _view, html} = live(conn, "/")
      assert html =~ "a-very-l..."
    end

    test "short session_id is not truncated", %{conn: conn} do
      {:ok, _log} =
        Hooks.create_hook_log(Map.put(@valid_attrs, "session_id", "abc"))

      {:ok, _view, html} = live(conn, "/")
      assert html =~ "abc"
    end

    test "timestamp is formatted", %{conn: conn} do
      {:ok, _log} = Hooks.create_hook_log(@valid_attrs)
      {:ok, _view, html} = live(conn, "/")
      # Timestamps are formatted as HH:MM:SS.fff
      assert html =~ ~r/\d{2}:\d{2}:\d{2}\.\d{3}/
    end

    test "nil tool_name renders empty", %{conn: conn} do
      {:ok, _log} =
        Hooks.create_hook_log(Map.delete(@valid_attrs, "tool_name"))

      {:ok, _view, html} = live(conn, "/")
      assert html =~ "PreToolUse"
    end
  end
end
