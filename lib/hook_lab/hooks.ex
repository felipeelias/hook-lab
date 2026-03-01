defmodule HookLab.Hooks do
  @moduledoc false

  import Ecto.Query

  alias HookLab.Hooks.HookLog
  alias HookLab.Repo

  def create_hook_log(attrs) do
    result =
      %HookLog{}
      |> HookLog.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, hook_log} ->
        Phoenix.PubSub.broadcast(HookLab.PubSub, "hook_logs", {:new_hook_log, hook_log})
        {:ok, hook_log}

      error ->
        error
    end
  end

  def list_hook_logs(filters \\ %{}) do
    HookLog
    |> order_by(desc: :inserted_at)
    |> limit(100)
    |> apply_filters(filters)
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {"hook_event_name", value}, query ->
        where(query, [h], h.hook_event_name == ^value)

      {"tool_name", value}, query ->
        where(query, [h], h.tool_name == ^value)

      {"session_id", value}, query ->
        where(query, [h], h.session_id == ^value)

      {"cwd", value}, query ->
        where(query, [h], h.cwd == ^value)

      {"permission_mode", value}, query ->
        where(query, [h], h.permission_mode == ^value)

      {"model", value}, query ->
        where(query, [h], h.model == ^value)

      _other, query ->
        query
    end)
  end
end
