defmodule CodeStats.RememberMe do
  @moduledoc """
  This plug provides "remember me" functionality.

  With the plug a long term cookie can be added into the request.
  Having the cookie will allow the user to log in as that user later.

  Cookie is not renewed automatically, so it must be renewed by user
  every @cookie_age seconds.

  Note: Must be run after fetch_cookies and fetch_session!
  """

  @cookie_name "_codestats_remember_me"
  @cookie_age 60 * 60 * 24 * 365 # ~1 year, in seconds
  @cookie_opts [max_age: @cookie_age]

  import Plug.Conn

  alias CodeStats.AuthUtils

  def init(_opts) do
    # NOTHING
  end

  def call(conn, _opts) do
    with \
      false                     <- AuthUtils.is_authed?(conn),
      %{@cookie_name => cookie} <- conn.cookies,
      {:ok, id}                 <- unform_payload(conn, cookie)
    do
      AuthUtils.force_auth_user_id(conn, id)
    else
      # If an error occurred, ignore it
      _ -> conn
    end
  end

  @doc """
  Add the remember me cookie for the specified user.
  """
  @spec write_cookie(%Plug.Conn{}, %CodeStats.User{}) :: %Plug.Conn{}
  def write_cookie(conn, %CodeStats.User{id: id}) do
    put_resp_cookie(conn, @cookie_name, form_payload(conn, id), @cookie_opts)
  end

  @doc """
  Remove remember me cookie.
  """
  @spec kill_cookie(%Plug.Conn{}) :: %Plug.Conn{}
  def kill_cookie(conn) do
    delete_resp_cookie(conn, @cookie_name)
  end

  defp form_payload(conn, id) do
    Phoenix.Token.sign(conn, @cookie_name, id)
  end

  defp unform_payload(conn, payload) do
    Phoenix.Token.verify(conn, @cookie_name, payload)
  end
end
