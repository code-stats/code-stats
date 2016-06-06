defmodule CodeStats.ErrorView do
  use CodeStats.Web, :view

  def render("404.html", _assigns) do
    raw """
    <div class="jumbotron">
      <h1>Not found</h1>
      <p class="lead">
        The page you were looking for does not exist.
      </p>
    </div>
    """
  end

  def render("404.json", _assigns) do
    %{error: "Route not found."}
  end

  def render("500.html", _assigns) do
    raw """
    <div class="jumbotron">
      <h1>Internal server error</h1>
      <p class="lead">
        The server some kind of exploded.
      </p>
    </div>
    """
  end

  def render("500.json", _assigns) do
    %{error: "The server some kind of exploded."}
  end

  def render("403.html", _assigns) do
    raw """
    <div class="jumbotron">
      <h1>Forbidden</h1>
      <p class="lead">
        Either you are not logged in or you tried doing something you're not allowed to do.
      </p>
    </div>
    """
  end

  def render("403.json", _assigns) do
    %{error: "You are not allowed to do that."}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
