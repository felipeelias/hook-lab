defmodule HookLabWeb.ErrorHTMLTest do
  use HookLabWeb.ConnCase, async: true

  alias HookLabWeb.ErrorHTML

  test "renders 404.html" do
    assert ErrorHTML.render("404.html", []) =~ "Not Found"
  end

  test "renders 500.html" do
    assert ErrorHTML.render("500.html", []) =~ "Internal Server Error"
  end
end
