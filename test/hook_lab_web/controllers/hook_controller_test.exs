defmodule HookLabWeb.HookControllerTest do
  use HookLabWeb.ConnCase

  test "POST /api/hooks creates a hook log", %{conn: conn} do
    payload = %{
      "session_id" => "test-session-123",
      "hook_event_name" => "PreToolUse",
      "tool_name" => "Bash",
      "tool_input" => %{"command" => "echo hello"},
      "cwd" => "/tmp",
      "permission_mode" => "default",
      "transcript_path" => "/tmp/t.jsonl"
    }

    conn = post(conn, ~p"/api/hooks", payload)
    assert json_response(conn, 200) == %{}
  end

  test "POST /api/hooks returns 422 for missing required fields", %{conn: conn} do
    conn = post(conn, ~p"/api/hooks", %{"tool_name" => "Bash"})
    assert json_response(conn, 422) == %{"error" => "invalid"}
  end
end
