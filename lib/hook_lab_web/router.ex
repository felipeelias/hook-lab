defmodule HookLabWeb.Router do
  use HookLabWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HookLabWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HookLabWeb do
    pipe_through :browser

    live "/", HookLogLive.Index
  end

  scope "/api", HookLabWeb do
    pipe_through :api

    post "/hooks", HookController, :create
  end
end
