defmodule CodeStatsWeb.ErrorViewTest do
  use CodeStatsWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "render 500.html", %{conn: conn} do
    assert is_binary(render_to_string(CodeStatsWeb.ErrorView, "500.html", [conn: conn]))
  end

  test "render any other", %{conn: conn} do
    assert is_binary(render_to_string(CodeStatsWeb.ErrorView, "505.html", [conn: conn]))
  end
end
