defmodule CodeStats.AuthController do
  use CodeStats.Web, :controller

  alias CodeStats.AuthUtils
  alias CodeStats.User

  def render_login(conn, _params) do
    render(conn, "login.html")
  end

  def render_signup(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "signup.html", changeset: changeset)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    with %User{} = user <- AuthUtils.get_user(username),
      %Plug.Conn{} = conn <- AuthUtils.auth_user(conn, user, password) do
        conn
      end
    |> case do
      %Plug.Conn{} = conn ->
        conn
        |> redirect(to: page_path(conn, :index))

      ret ->
        # If ret is nil, user was not found -> run dummy auth to prevent user enumeration
        # But they can enumerate with the signin form anyway lol
        # TODO: Add CAPTCHA to signup form
        if ret == nil, do: AuthUtils.dummy_auth_user()

        conn
        |> assign(:username_input, username)
        |> put_status(404)
        |> put_flash(:error, "Wrong username and/or password!")
        |> render("login.html")
    end
  end

  def signup(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    case AuthUtils.create_user(changeset) do
      %Ecto.Changeset{} = changeset ->
        conn
        |> put_status(400)
        |> render("signup.html", changeset: changeset)

      %User{} ->
        conn
        |> put_flash(:success, "Great success! Your account was created and you can now log in with the details you provided.")
        |> redirect(to: auth_path(conn, :render_login))
    end
  end

  def logout(conn, _params) do
    conn
    |> AuthUtils.unauth_user()
    |> redirect(to: page_path(conn, :index))
  end
end
