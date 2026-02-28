defmodule HookLab.Repo.Migrations.CreateHookLogs do
  use Ecto.Migration

  def change do
    create table(:hook_logs) do
      add :session_id, :string, null: false
      add :transcript_path, :string
      add :cwd, :string
      add :permission_mode, :string
      add :hook_event_name, :string, null: false
      add :tool_name, :string
      add :tool_input, :map
      add :tool_response, :map
      add :tool_use_id, :string
      add :source, :string
      add :model, :string
      add :prompt, :text
      add :raw_payload, :map, null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:hook_logs, [:session_id])
    create index(:hook_logs, [:hook_event_name])
    create index(:hook_logs, [:tool_name])
  end
end
