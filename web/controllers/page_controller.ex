defmodule CodeStats.PageController do
  use CodeStats.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo
  alias CodeStats.XP
  alias CodeStats.Pulse
  alias CodeStats.Language

  def index(conn, _params) do
    now = Calendar.DateTime.now_utc()
    then = Calendar.DateTime.subtract!(now, 3600 * 12)

    total_xp_q = from x in XP,
      select: sum(x.amount)

    total_xp = case Repo.one(total_xp_q) do
      nil -> 0
      ret -> ret
    end

    last_12h_xp_q = from x in XP,
      join: p in Pulse, on: p.id == x.pulse_id,
      where: p.sent_at >= ^then,
      select: sum(x.amount)

    last_12h_xp = case Repo.one(last_12h_xp_q) do
      nil -> 0
      ret -> ret
    end

    most_popular_q = from x in XP,
      join: l in Language, on: l.id == x.language_id,
      group_by: l.id,
      order_by: [desc: sum(x.amount)],
      select: {l.name, sum(x.amount)},
      limit: 10

    most_popular = case Repo.all(most_popular_q) do
      nil -> []
      ret -> ret
    end

    most_popular_12h_q = from x in XP,
      join: l in Language, on: l.id == x.language_id,
      join: p in Pulse, on: p.id == x.pulse_id,
      where: p.sent_at >= ^then,
      group_by: l.id,
      order_by: [desc: sum(x.amount)],
      select: {l.name, sum(x.amount)},
      limit: 10

    most_popular_12h = case Repo.all(most_popular_12h_q) do
      nil -> []
      ret -> ret
    end

    conn
    |> assign(:total_xp, total_xp)
    |> assign(:last_12h_xp, last_12h_xp)
    |> assign(:most_popular, most_popular)
    |> assign(:most_popular_12h, most_popular_12h)
    |> render("index.html")
  end

  def api_docs(conn, _params) do
    render(conn, "api_docs.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end
end
