defmodule HookLabWeb.ErrorJSONTest do
  use HookLabWeb.ConnCase, async: true

  alias HookLabWeb.ErrorJSON

  test "renders 404.json" do
    assert ErrorJSON.render("404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert ErrorJSON.render("500.json", []) == %{errors: %{detail: "Internal Server Error"}}
  end
end
