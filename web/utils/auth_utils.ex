defmodule CodeStats.AuthUtils do
  @moduledoc """
  Authentication related utilities.
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias CodeStats.{
    Repo,
    User,
    Machine,
    SetSessionUser
  }

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
  @spec get_current_user_id(%Conn{}) :: number | nil
  def get_current_user_id(conn) do
    Conn.get_session(conn, @auth_key)
  end

  @doc """
  Get current user model of the authenticated user.

  Returns nil if the user is not authenticated.
  """
  @spec get_current_user(%Conn{}) :: %User{} | nil
  def get_current_user(conn) do
    SetSessionUser.get_user_data(conn)
  end

  @doc """
  Get user with the given username.

  If second argument is true, case insensitive search is used instead.

  Returns nil if user was not found.
  """
  @spec get_user(String.t, boolean) :: %User{} | nil
  def get_user(username, case_insensitive \\ false) do
    query = case case_insensitive do
      false ->
        from u in User,
          where: u.username == ^username

      true ->
        from u in User,
          where: fragment("lower(?)", ^username) == fragment("lower(?)", u.username)
    end

    Repo.one(query)
  end

  @doc """
  Authenticate the given user in the given connection.

  Authentication status is saved in the session. Returns conn on success, :error on failure.
  """
  @spec auth_user(%Conn{}, %User{}, String.t) :: %Conn{} | :error
  def auth_user(%Conn{} = conn, %User{} = user, password) do
    if check_user_password(user, password) do
      force_auth_user_id(conn, user.id)
    else
      :error
    end
  end

  @doc """
  Put authentication status into session for given user ID.
  """
  def force_auth_user_id(%Conn{} = conn, id) do
    Conn.put_session(conn, @auth_key, id)
  end

  @doc """
  Unauthenticate (log out) the user from the connection.

  The whole session is destroyed.
  """
  @spec unauth_user(%Conn{}) :: %Conn{}
  def unauth_user(%Conn{} = conn) do
    Conn.configure_session(conn, drop: true)
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
  @spec delete_user(%User{}) :: boolean
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
    match?({%User{}, %Machine{}}, conn.private[@api_auth_key])
  end

  @doc """
  Authenticate a user in the given connection using the given API token.

  Authentication status is saved in the connection with the key @api_auth_key. The key will
  contain a tuple of the authenticated user and the machine they are using.

  If the given token is not valid, nothing is done to the connection.
  """
  @spec auth_user_api(%Conn{}, String.t) :: %Conn{}
  def auth_user_api(%Conn{} = conn, api_user_token) do
    with \
      {username, machine_id}  <- split_token(api_user_token),
      %User{} = user          <- get_user(username),
      %Machine{} = machine    <- get_machine(machine_id, user),
      {:ok, _}                <- MessageVerifier.verify(api_user_token,
                                                        conn.secret_key_base <> machine.api_salt)
    do
      Conn.put_private(conn, @api_auth_key, {user, machine})
    else
      _ -> conn
    end
  end

  @doc """
  Get the user and machine associated with the given connection.

  Returns nil if user is not API authenticated.
  """
  @spec get_api_details(%Conn{}) :: {%User{}, %Machine{}} | nil
  def get_api_details(%Conn{} = conn) do
    conn.private[@api_auth_key]
  end

  @doc """
  Get user's API key from user and machine data.

  Connection needs to be given to get the secret key base.
  """
  @spec get_api_key(%Conn{}, %User{}, %Machine{}) :: String.t
  def get_api_key(%Conn{} = conn, %User{} = user, %Machine{} = machine) do
    MessageVerifier.sign(form_payload(user.username, machine.id),
                         conn.secret_key_base <> machine.api_salt)
  end

  @doc """
  Checks if the given password matches the given user's password.
  """
  @spec check_user_password(%User{}, String.t) :: boolean
  def check_user_password(%User{} = user, password) do
    Bcrypt.checkpw(password, user.password)
  end

  defp form_payload(username, machine_id) do
    Base.url_encode64(username) <> "##" <> Base.url_encode64(Integer.to_string(machine_id))
  end

  defp unform_payload(payload) do
    with \
      [username, machine] <- String.split(payload, "##"),
      {:ok, username}     <- Base.url_decode64(username),
      {:ok, machine}      <- Base.url_decode64(machine)
    do
      {username, machine}
    else
      _ -> :error
    end
  end

  defp split_token(token) do
    # Try new style token split first, then old style
    content = case String.split(token, ".") do
      [_, content, _] -> content
      _ -> String.split(token, "##") |> Enum.at(0)
    end

    with \
      {:ok, content}      <- Base.decode64(content, padding: false),
      {username, machine} <- unform_payload(content)
    do
      {username, machine}
    else
      # Given token was malformed in some way
      _ -> :error
    end
  end

  defp get_machine(machine_id, user) do
    query = from m in Machine,
      where: m.id == ^machine_id and
             m.user_id == ^user.id and
             m.active == true

    Repo.one(query)
  end
end
