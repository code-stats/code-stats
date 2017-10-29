defmodule CodeStatsWeb.SetSessionUserPlug do
  @moduledoc """
  This module sets the data of the current session authenticated user into the conn.

  is_authed? should be used to check if user data is available before using the data set by
  this plug.
  """

  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias CodeStatsWeb.AuthUtils
  alias CodeStats.Repo
  alias CodeStats.User

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if AuthUtils.is_authed?(conn) do
      id = AuthUtils.get_current_user_id(conn)
      query = from u in User,
        where: u.id == ^id

      put_private(conn, AuthUtils.private_info_key(), Repo.one(query))
    else
      put_private(conn, AuthUtils.private_info_key(), nil)
    end
  end
end
