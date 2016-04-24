defmodule CodeStats.PageController do
  use CodeStats.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def api_docs(conn, _params) do
    render(conn, "api_docs.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end
end
