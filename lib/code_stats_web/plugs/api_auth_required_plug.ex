defmodule CodeStatsWeb.APIAuthRequiredPlug do
  @moduledoc """
  This plug requires the user to be authenticated with API authentication.

  If the user is not authenticated, an error code will be returned.
  """

  @api_auth_header "x-api-token"

  import Plug.Conn
  alias Plug.Conn

  alias CodeStatsWeb.AuthUtils

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    ret =
      with \
        [auth_header]   <- get_req_header(conn, @api_auth_header),
        %Conn{} = conn  <- AuthUtils.auth_user_api(conn, auth_header),
        true            <- AuthUtils.is_api_authed?(conn)
      do
        conn
      end

    case ret do
      %Conn{} = conn -> conn

      _ ->
        conn
        |> send_resp(403, ~S({"error": "You must be authenticated"}))
        |> halt()
    end
  end
end
