defmodule CodeStatsWeb.AuthNotAllowed do
  @moduledoc """
  This plug forbids the user from being authenticated with session authentication.

  If the user is authenticated, they will be redirected to their profile.
  """

  import Plug.Conn

  alias CodeStatsWeb.AuthUtils
  alias CodeStatsWeb.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    unless AuthUtils.is_authed?(conn) do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: Helpers.profile_path(conn, :my_profile))
      |> halt
    end
  end
end
