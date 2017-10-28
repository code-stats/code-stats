defmodule CodeStatsWeb.AuthRequiredPlug do
  @moduledoc """
  This plug requires the user to be authenticated with session authentication.

  If the user is not authenticated, an error will be rendered.
  """

  import Plug.Conn

  alias CodeStatsWeb.AuthUtils

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if AuthUtils.is_authed?(conn) do
      conn
    else
      conn
      |> put_status(403)
      |> Phoenix.Controller.put_view(CodeStats.ErrorView)
      |> Phoenix.Controller.render("403.html")
      |> halt
    end
  end
end
