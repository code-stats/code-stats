defmodule CodeStatsWeb.BattleController do
  use CodeStatsWeb, :controller

  def battle(conn, _params) do
    conn
    |> put_layout("battle.html")
    |> render("battle.html")
  end
end
