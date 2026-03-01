defmodule HookLabWeb.HookLogLive.Index do
  use HookLabWeb, :live_view

  alias HookLab.Hooks

  @filter_keys ~w(hook_event_name tool_name session_id cwd permission_mode model)

  @event_badge_classes %{
    "PreToolUse" => "badge-warning",
    "PostToolUse" => "badge-success",
    "SessionStart" => "badge-info",
    "SessionEnd" => "badge-neutral",
    "Stop" => "badge-error",
    "UserPromptSubmit" => "badge-primary",
    "Notification" => "badge-accent",
    "SubagentStart" => "badge-secondary",
    "SubagentStop" => "badge-secondary"
  }

  defp toggle_detail(dom_id) do
    JS.toggle(to: "##{dom_id}-detail")
    |> JS.toggle_class("rotate-180", to: "##{dom_id}-chevron")
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(HookLab.PubSub, "hook_logs")
    end

    {:ok,
     socket
     |> assign(:filters, %{})
     |> assign(:page_title, "Hook Logs")
     |> stream(:hook_logs, Hooks.list_hook_logs())}
  end

  @impl true
  def handle_info({:new_hook_log, hook_log}, socket) do
    if matches_filters?(hook_log, socket.assigns.filters) do
      {:noreply, stream_insert(socket, :hook_logs, hook_log, at: 0)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("filter", params, socket) do
    filters =
      params
      |> Map.take(@filter_keys)
      |> Enum.reject(fn {_k, v} -> v == "" end)
      |> Map.new()

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> stream(:hook_logs, Hooks.list_hook_logs(filters), reset: true)}
  end

  defp matches_filters?(hook_log, filters) do
    Enum.all?(filters, fn {key, value} ->
      Map.get(hook_log, String.to_existing_atom(key)) == value
    end)
  end

  defp event_badge_class(event_name) do
    Map.get(@event_badge_classes, event_name, "badge-neutral")
  end

  defp truncate(nil, _), do: ""
  defp truncate(str, max_len) when byte_size(str) <= max_len, do: str
  defp truncate(str, max_len), do: String.slice(str, 0, max_len) <> "..."

  defp format_timestamp(dt) do
    Calendar.strftime(dt, "%H:%M:%S.%f")
    |> String.slice(0, 12)
  end

  defp format_json(nil), do: ""

  defp format_json(map) when is_map(map) do
    Jason.encode!(map, pretty: true)
  end

  defp format_json(other), do: inspect(other)
end
