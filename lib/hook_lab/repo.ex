defmodule HookLab.Repo do
  use Ecto.Repo,
    otp_app: :hook_lab,
    adapter: Ecto.Adapters.SQLite3
end
