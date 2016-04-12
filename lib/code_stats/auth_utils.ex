defmodule CodeStats.AuthUtils do
  @moduledoc """
  Authentication related utilities.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias CodeStats.Repo

  alias CodeStats.User
  alias Comeonin.Bcrypt
  alias Plug.Conn
  alias Plug.Crypto.MessageVerifier

  @auth_key     :codestats_user
  @api_auth_key :codestats_api_user

  @doc """
  Is the current user authenticated?
  """
  @spec is_authed?(%Conn{}) :: boolean
  def is_authed?(%Conn{} = conn) do
    match?(number when is_integer(number), Conn.get_session(conn, @auth_key))
  end

  @doc """
  Get ID of current user from the session.

  Returns nil if user is not authenticated.
  """
  @spec get_current_user(%Conn{}) :: number | nil
  def get_current_user(conn) do
    Conn.get_session(conn, @auth_key)
  end

  @doc """
  Get user with the given username.

  Returns nil if user was not found.
  """
  @spec get_user(String.t) :: %User{} | nil
  def get_user(username) do
    query = from u in User,
      where: u.username == ^username

    Repo.one(query)
  end

  @doc """
  Authenticate the given user in the given connection.

  Authentication status is saved in the session. Returns conn on success, :error on failure.
  """
  @spec auth_user(%Conn{}, %User{}, String.t) :: %Conn{} | :error
  def auth_user(%Conn{} = conn, %User{} = user, password) do
    if check_user_password(user, password) do
      Conn.put_session(conn, @auth_key, user.id)
    else
      :error
    end
  end

  @doc """
  Unauthenticate (log out) the user from the connection.

  The session's authentication status is cleared.
  """
  @spec unauth_user(%Conn{}) :: %Conn{}
  def unauth_user(%Conn{} = conn) do
    Conn.put_session(conn, @auth_key, nil)
  end

  @doc """
  Fake a user authentication.

  Uses some CPU cycles to make it look like we authenticated a user and checked their
  password. This makes it harder to enumerate users in the system.
  """
  @spec dummy_auth_user() :: nil
  def dummy_auth_user() do
    Bcrypt.dummy_checkpw()
  end

  @doc """
  Create a new user and save them to the database.

  Returns an Ecto changeset if validation errors happened.
  """
  @spec create_user(%Changeset{}) :: %User{} | %Changeset{}
  def create_user(changeset) do
    changeset
    |> Repo.insert()
    |> case do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  @doc """
  Update a user's data in the database.

  Returns an Ecto changeset if validation errors happened.
  """
  @spec update_user(%Changeset{}) :: %User{} | %Changeset{}
  def update_user(changeset) do
    changeset
    |> Repo.update()
    |> case do
      {:ok, user} -> user
      {:error, changeset} -> changeset
    end
  end

  @doc """
  Delete the given user.

  Returns true if succeeded, false if failed.
  """
  def delete_user(user) do
    case Repo.delete(user) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  @doc """
  Is the current user authenticated to the API?
  """
  @spec is_api_authed?(%Conn{}) :: boolean
  def is_api_authed?(%Conn{} = conn) do
    match?(%User{}, conn.private[@api_auth_key])
  end

  @doc """
  Authenticate a user in the given connection using the given API token.

  Authentication status is saved in the connection with the key @api_auth_key.
  """
  @spec auth_user_api(%Conn{}, String.t) :: %Conn{} | :error | nil
  def auth_user_api(%Conn{} = conn, api_user_token) do
    with username <- split_username_from_token(api_user_token),
      %User{} = user <- get_user(username),
      {:ok, _} <- MessageVerifier.verify(api_user_token, conn.secret_key_base <> user.api_salt)
      do
        Conn.put_private(conn, @api_auth_key, user)
      end
  end

  @doc """
  Get user's API key from user data.

  Connection needs to be given to get the secret key base.
  """
  @spec get_api_key(%Conn{}, %User{}) :: String.t
  def get_api_key(%Conn{} = conn, %User{} = user) do
    MessageVerifier.sign(user.username, conn.secret_key_base <> user.api_salt)
  end

  @doc """
  Checks if the given password matches the given user's password.
  """
  @spec check_user_password(%User{}, String.t) :: boolean
  def check_user_password(%User{} = user, password) do
    Bcrypt.checkpw(password, user.password)
  end

  defp split_username_from_token(token) do
    [username, _] = String.split(token, "##")
    {:ok, username} = Base.url_decode64(username)
    username
  end
end