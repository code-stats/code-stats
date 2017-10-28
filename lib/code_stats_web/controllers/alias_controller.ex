defmodule CodeStatsWeb.AliasController do
  use CodeStatsWeb, :controller

  alias CodeStats.{
    Repo,
    Language
  }

  def list(conn, _params) do
    conn
    |> assign(:title, "Language aliases")
    |> assign(:aliases, get_aliases())
    |> render("aliases.html")
  end

  defp get_aliases() do
    (from l in Language,
      where: is_nil(l.alias_of_id),
      preload: :aliases)
    |> Repo.all()
  end
end
