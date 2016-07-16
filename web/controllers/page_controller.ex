defmodule CodeStats.PageController do
  use CodeStats.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias CodeStats.{
    Repo,
    XP,
    Pulse,
    Language,
    CacheService
  }

  @popular_languages_limit 10

  def index(conn, _params) do
    now = Calendar.DateTime.now_utc()
    then = Calendar.DateTime.subtract!(now, 3600 * 12)

    # Load total language XPs from cache and use them to populate total XP and
    # list of most popular languages
    total_lang_xps = CacheService.get_total_language_xps()
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)

    total_xp = Enum.reduce(total_lang_xps, 0, fn {_, amount}, acc -> amount + acc end)

    most_popular = Enum.slice(total_lang_xps, 0..(@popular_languages_limit - 1))

    last_12h_xp_q = from x in XP,
      join: p in Pulse, on: p.id == x.pulse_id,
      where: p.sent_at >= ^then,
      select: sum(x.amount)

    last_12h_xp = case Repo.one(last_12h_xp_q) do
      nil -> 0
      ret -> ret
    end

    most_popular_12h_q = from x in XP,
      join: l in Language, on: l.id == x.language_id,
      join: p in Pulse, on: p.id == x.pulse_id,
      where: p.sent_at >= ^then,
      group_by: l.id,
      order_by: [desc: sum(x.amount)],
      select: {l.name, sum(x.amount)},
      limit: @popular_languages_limit

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
    conn
    |> assign(:title, "API docs")
    |> render("api_docs.html")
  end

  def terms(conn, _params) do
    conn
    |> assign(:title, "Legal")
    |> render("terms.html")
  end

  def plugins(conn, _params) do
    conn
    |> assign(:title, "Plugins")
    |> render("plugins.html")
  end

  def changes(conn, _params) do
    conn
    |> assign(:title, "Changes")
    |> render("changes.html")
  end

  def irc(conn, _params) do
    conn
    |> assign(:title, "IRC")
    |> render("irc.html")
  end
end
