defmodule CodeStats.ProfileController do
  use CodeStats.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo

  alias CodeStats.AuthUtils
  alias CodeStats.User
  alias CodeStats.SetSessionUser
  alias CodeStats.Pulse
  alias CodeStats.XP
  alias CodeStats.Language

  def my_profile(conn, _params) do
    user = SetSessionUser.get_user_data(conn)
    redirect(conn, to: profile_path(conn, :profile, user.username))
  end

  def profile(conn, %{"username" => username}) do
    case AuthUtils.get_user(username) do
      nil -> render_404(conn)

      %User{} = user ->
        case {user.private_profile, AuthUtils.get_current_user(conn) == user.id} do
          {true, true} -> render_profile(conn, user)
          {true, false} -> render_404(conn)
          {false, _} -> render_profile(conn, user)
        end
    end
  end

  def render_404(conn) do
    conn
    |> put_status(404)
    |> render(CodeStats.ErrorView, "404.html")
  end

  def render_profile(conn, user) do
    xps = User.update_cached_xps(user)
    |> Enum.sort(fn a, b -> a.amount >= b.amount end)
    new_xps = get_latest_xps(user)

    total_xp = Enum.reduce(xps, 0, fn xp, acc -> acc + xp.amount end)
    total_new_xp = Enum.reduce(Map.values(new_xps), 0, fn amount, acc -> acc + amount end)

    {highlighted_xps, more_xps} = Enum.split(xps, 10)

    conn
    |> assign(:user, user)
    |> assign(:total_xp, total_xp)
    |> assign(:xps, highlighted_xps)
    |> assign(:more_xps, more_xps)
    |> assign(:new_xps, new_xps)
    |> assign(:total_new_xp, total_new_xp)
    |> render("profile.html")
  end

  defp get_latest_xps(user) do
    now = Calendar.DateTime.now_utc()
    then = Calendar.DateTime.subtract!(now, 3600 * 12)

    xps_q = from x in XP,
      join: p in Pulse, on: p.id == x.pulse_id,
      join: l in Language, on: l.id == x.language_id,
      where: p.user_id == ^user.id and p.sent_at >= ^then,
      select: {x.amount, l.name}

    xps = case Repo.all(xps_q) do
      nil -> []
      ret -> ret
    end

    Enum.reduce(xps, %{}, fn {xp, language}, acc ->
      amount = Map.get(acc, language, 0) + xp
      Map.put(acc, language, amount)
    end)
  end
end
