defmodule CodeStats.BattleController do
  use CodeStats.Web, :controller

  def battle(conn, _params) do
    conn
    |> put_layout("battle.html")
    |> render("battle.html")
  end
end
