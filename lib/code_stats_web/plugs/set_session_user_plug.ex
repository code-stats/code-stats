defmodule CodeStatsWeb.SetSessionUserPlug do
  @moduledoc """
  This module sets the data of the current session authenticated user into the conn.

  is_authed? should be used to check if user data is available before using the data set by
  this plug.
  """

  @private_info_key :_codestats_session_user

  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias Plug.Conn

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

      put_private(conn, @private_info_key, Repo.one(query))
    else
      put_private(conn, @private_info_key, nil)
    end
  end

  @doc """
  Get the data of the currently authenticated user.

  Returns nil if the user is not authenticated.
  """
  @spec get_user_data(%Conn{}) :: %User{} | nil
  def get_user_data(conn) do
    conn.private[@private_info_key]
  end
end
