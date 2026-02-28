import Config

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/hook_lab start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :hook_lab, HookLabWeb.Endpoint, server: true
end

default_bind_ip = if config_env() == :prod, do: "0.0.0.0", else: nil

bind_ip =
  case System.get_env("BIND_IP", default_bind_ip) do
    nil ->
      nil

    ip_str ->
      {:ok, ip} = :inet.parse_address(String.to_charlist(ip_str))
      ip
  end

http_opts = [port: String.to_integer(System.get_env("PORT", "4000"))]
http_opts = if bind_ip, do: Keyword.put(http_opts, :ip, bind_ip), else: http_opts

config :hook_lab, HookLabWeb.Endpoint, http: http_opts

if config_env() == :prod do
  database_path = System.get_env("DATABASE_PATH", "/app/data/hook_lab.db")

  config :hook_lab, HookLab.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT", "4000"))

  config :hook_lab, HookLabWeb.Endpoint,
    url: [host: host, port: port, scheme: "http"],
    secret_key_base: secret_key_base
end
