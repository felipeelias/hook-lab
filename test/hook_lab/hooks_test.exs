defmodule HookLab.HooksTest do
  use HookLab.DataCase, async: true

  alias HookLab.Hooks
  alias HookLab.Hooks.HookLog

  @valid_attrs %{
    "session_id" => "sess-001",
    "hook_event_name" => "PreToolUse",
    "tool_name" => "Bash",
    "tool_input" => %{"command" => "echo hi"},
    "cwd" => "/tmp",
    "permission_mode" => "default",
    "model" => "claude-sonnet",
    "raw_payload" => %{"foo" => "bar"}
  }

  describe "create_hook_log/1" do
    test "success with valid attrs" do
      assert {:ok, %HookLog{} = log} = Hooks.create_hook_log(@valid_attrs)
      assert log.session_id == "sess-001"
      assert log.hook_event_name == "PreToolUse"
      assert log.tool_name == "Bash"
      assert log.tool_input == %{"command" => "echo hi"}
      assert log.cwd == "/tmp"
      assert log.permission_mode == "default"
      assert log.model == "claude-sonnet"
      assert log.raw_payload == %{"foo" => "bar"}
    end

    test "failure with missing required fields" do
      assert {:error, changeset} = Hooks.create_hook_log(%{})
      assert %{session_id: ["can't be blank"]} = errors_on(changeset)
      assert %{hook_event_name: ["can't be blank"]} = errors_on(changeset)
      assert %{raw_payload: ["can't be blank"]} = errors_on(changeset)
    end

    test "broadcasts on PubSub hook_logs topic" do
      Phoenix.PubSub.subscribe(HookLab.PubSub, "hook_logs")

      {:ok, hook_log} = Hooks.create_hook_log(@valid_attrs)

      assert_receive {:new_hook_log, ^hook_log}
    end

    test "does not broadcast on failure" do
      Phoenix.PubSub.subscribe(HookLab.PubSub, "hook_logs")

      {:error, _changeset} = Hooks.create_hook_log(%{})

      refute_receive {:new_hook_log, _}
    end
  end

  describe "list_hook_logs/0" do
    test "returns all logs ordered by inserted_at desc" do
      {:ok, log1} = Hooks.create_hook_log(@valid_attrs)
      {:ok, log2} = Hooks.create_hook_log(Map.put(@valid_attrs, "session_id", "sess-002"))

      logs = Hooks.list_hook_logs()
      ids = Enum.map(logs, & &1.id)

      assert log2.id in ids
      assert log1.id in ids
      assert hd(ids) == log2.id
    end

    test "returns empty list when no logs exist" do
      assert Hooks.list_hook_logs() == []
    end
  end

  describe "list_hook_logs/1 filters" do
    setup do
      {:ok, log1} =
        Hooks.create_hook_log(%{
          "session_id" => "sess-A",
          "hook_event_name" => "PreToolUse",
          "tool_name" => "Bash",
          "cwd" => "/home",
          "permission_mode" => "default",
          "model" => "claude-sonnet",
          "raw_payload" => %{}
        })

      {:ok, log2} =
        Hooks.create_hook_log(%{
          "session_id" => "sess-B",
          "hook_event_name" => "PostToolUse",
          "tool_name" => "Read",
          "cwd" => "/tmp",
          "permission_mode" => "plan",
          "model" => "claude-opus",
          "raw_payload" => %{}
        })

      %{log1: log1, log2: log2}
    end

    test "filters by hook_event_name", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"hook_event_name" => "PreToolUse"})
      ids = Enum.map(results, & &1.id)
      assert log1.id in ids
      refute log2.id in ids
    end

    test "filters by tool_name", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"tool_name" => "Read"})
      ids = Enum.map(results, & &1.id)
      refute log1.id in ids
      assert log2.id in ids
    end

    test "filters by session_id", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"session_id" => "sess-A"})
      ids = Enum.map(results, & &1.id)
      assert log1.id in ids
      refute log2.id in ids
    end

    test "filters by cwd", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"cwd" => "/tmp"})
      ids = Enum.map(results, & &1.id)
      refute log1.id in ids
      assert log2.id in ids
    end

    test "filters by permission_mode", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"permission_mode" => "plan"})
      ids = Enum.map(results, & &1.id)
      refute log1.id in ids
      assert log2.id in ids
    end

    test "filters by model", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"model" => "claude-sonnet"})
      ids = Enum.map(results, & &1.id)
      assert log1.id in ids
      refute log2.id in ids
    end

    test "multiple filters combined", %{log1: log1, log2: log2} do
      results =
        Hooks.list_hook_logs(%{
          "hook_event_name" => "PostToolUse",
          "tool_name" => "Read",
          "session_id" => "sess-B"
        })

      ids = Enum.map(results, & &1.id)
      refute log1.id in ids
      assert log2.id in ids
    end

    test "unknown filter keys are ignored", %{log1: log1, log2: log2} do
      results = Hooks.list_hook_logs(%{"unknown_key" => "value"})
      ids = Enum.map(results, & &1.id)
      assert log1.id in ids
      assert log2.id in ids
    end
  end
end
