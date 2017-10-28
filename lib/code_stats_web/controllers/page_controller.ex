defmodule CodeStatsWeb.PageController do
  use CodeStatsWeb, :controller

  alias CodeStats.{
    CacheService
  }

  @popular_languages_limit 10

  def index(conn, _params) do
    # Load total language XPs from cache and use them to populate total XP and
    # list of most popular languages
    total_lang_xps = CacheService.get_total_language_xps()
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)

    total_xp = Enum.reduce(total_lang_xps, 0, fn {_, amount}, acc -> amount + acc end)

    most_popular = Enum.slice(total_lang_xps, 0..(@popular_languages_limit - 1))

    conn
    |> assign(:total_xp, total_xp)
    |> assign(:most_popular, most_popular)
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

  def contact(conn, _params) do
    conn
    |> assign(:title, "Contact")
    |> render("contact.html")
  end
end
