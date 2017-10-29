defmodule CodeStatsWeb.ErrorView do
  use CodeStatsWeb, :view

  def render("404.html", assigns) do
    assigns = non_crash_error_assigns(assigns)
    render(__MODULE__, "error_404.html", assigns)
  end

  def render("404.json", _assigns) do
    %{error: "Route not found."}
  end

  def render("500.html", _assigns) do
    render(__MODULE__, "error_500.html")
  end

  def render("500.json", _assigns) do
    %{error: "The server some kind of exploded."}
  end

  def render("403.html", assigns) do
    assigns = non_crash_error_assigns(assigns)
    render("error_403.html", assigns)
  end

  def render("403.json", _assigns) do
    %{error: "You are not allowed to do that."}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end

  # Assigns for error pages that are not crashes
  defp non_crash_error_assigns(assigns) do
    Map.merge(assigns, %{
      layout: {__MODULE__, "error_layout.html"}
    })
  end
end
