defmodule CodeStatsWeb.PageControllerTest do
  use CodeStatsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert is_binary(html_response(conn, 200))
  end
end
