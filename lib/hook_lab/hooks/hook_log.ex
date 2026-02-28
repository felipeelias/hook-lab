defmodule HookLab.Hooks.HookLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hook_logs" do
    field :session_id, :string
    field :transcript_path, :string
    field :cwd, :string
    field :permission_mode, :string
    field :hook_event_name, :string
    field :tool_name, :string
    field :tool_input, :map
    field :tool_response, :map
    field :tool_use_id, :string
    field :source, :string
    field :model, :string
    field :prompt, :string
    field :raw_payload, :map

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(hook_log, attrs) do
    hook_log
    |> cast(attrs, [
      :session_id,
      :transcript_path,
      :cwd,
      :permission_mode,
      :hook_event_name,
      :tool_name,
      :tool_input,
      :tool_response,
      :tool_use_id,
      :source,
      :model,
      :prompt,
      :raw_payload
    ])
    |> validate_required([:session_id, :hook_event_name, :raw_payload])
  end
end
