defmodule HookLabWeb.HookController do
  use HookLabWeb, :controller

  alias HookLab.Hooks

  def create(conn, params) do
    attrs = %{
      session_id: params["session_id"],
      transcript_path: params["transcript_path"],
      cwd: params["cwd"],
      permission_mode: params["permission_mode"],
      hook_event_name: params["hook_event_name"],
      tool_name: params["tool_name"],
      tool_input: params["tool_input"],
      tool_response: params["tool_response"],
      tool_use_id: params["tool_use_id"],
      source: params["source"],
      model: params["model"],
      prompt: params["prompt"],
      raw_payload: params
    }

    case Hooks.create_hook_log(attrs) do
      {:ok, _hook_log} -> json(conn, %{})
      {:error, _changeset} -> conn |> put_status(422) |> json(%{error: "invalid"})
    end
  end
end
