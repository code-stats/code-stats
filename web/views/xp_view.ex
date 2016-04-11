defmodule CodeStats.XPView do
  use CodeStats.Web, :view

  def render("show.json", %{xp: xp}) do
    %{data: render_one(xp, CodeStats.XPView, "xp.json")}
  end
end
