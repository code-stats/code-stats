defmodule CodeStats.ProfileController do
  use CodeStats.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo

  alias CodeStats.AuthUtils
  alias CodeStats.User
  alias CodeStats.SetSessionUser
  alias CodeStats.CachedXP

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
        xps = User.update_cached_xps(user)
        |> Enum.sort(fn a, b -> a.amount >= b.amount end)

        total_xp = Enum.reduce(xps, 0, fn xp, acc -> acc + xp.amount end)

        {highlighted_xps, more_xps} = Enum.split(xps, 10)

        conn
        |> assign(:user, user)
        |> assign(:total_xp, total_xp)
        |> assign(:xps, highlighted_xps)
        |> assign(:more_xps, more_xps)
        |> render("profile.html")
    end
  end
end
