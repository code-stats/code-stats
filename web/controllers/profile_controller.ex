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
        xps = get_xps(user)

        total_xp = Enum.reduce(xps, 0, fn xp, acc -> acc + xp.amount end)

        conn
        |> assign(:user, user)
        |> assign(:total_xp, total_xp)
        |> assign(:xps, xps)
        |> render("profile.html")
    end
  end

  defp get_xps(user) do
    (from cx in CachedXP,
      where: cx.user_id == ^user.id,
      preload: [:language],
      order_by: [desc: cx.amount])
    |> Repo.all()
  end
end
