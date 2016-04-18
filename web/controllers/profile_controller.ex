defmodule CodeStats.ProfileController do
  use CodeStats.Web, :controller

  alias CodeStats.AuthUtils
  alias CodeStats.User
  alias CodeStats.SetSessionUser

  def my_profile(conn, _params) do
    user = SetSessionUser.get_user_data(conn)
    redirect(conn, to: profile_path(conn, :profile, user.username))
  end

  def profile(conn, %{"username" => username}) do
    case AuthUtils.get_user(username) do
      nil ->
        conn
        |> put_status(404)
        |> render(CodeStats.ErrorView, "404.html")

      %User{} = user ->
        conn
        |> assign(:user, user)
        |> render("profile.html")
    end

    render(conn, "profile.html")
  end
end
