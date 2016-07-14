defmodule CodeStats.ProfileController do
  use CodeStats.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo

  alias CodeStats.{AuthUtils, PermissionUtils}
  alias CodeStats.User
  alias CodeStats.SetSessionUser
  alias CodeStats.Pulse
  alias CodeStats.XP
  alias CodeStats.Language
  alias CodeStats.Machine

  def my_profile(conn, _params) do
    user = SetSessionUser.get_user_data(conn)
    redirect(conn, to: profile_path(conn, :profile, user.username))
  end

  def profile(conn, %{"username" => username}) do
    fix_url_username(username)
    |> AuthUtils.get_user()
    |> case do
      nil -> render_404(conn)

      %User{} = user ->
        case PermissionUtils.can_access_profile?(AuthUtils.get_current_user(conn), user) do
          true -> render_profile(conn, user)
          false -> render_404(conn)
        end
    end
  end

  def render_404(conn) do
    conn
    |> put_status(404)
    |> render(CodeStats.ErrorView, "error_404.html")
  end

  def render_profile(conn, user) do
    now = Calendar.DateTime.now_utc()
    latest_xp_since = Calendar.DateTime.subtract!(now, 3600 * 12)

    xps = User.update_cached_xps(user)
    |> Enum.sort(fn a, b -> a.amount >= b.amount end)
    new_xps = get_latest_xps(user, latest_xp_since)
    {machine_xps, new_machine_xps} = get_machine_xps(user, latest_xp_since)
    days_coded = get_days_coded(user)

    total_xp = Enum.reduce(xps, 0, fn xp, acc -> acc + xp.amount end)
    total_new_xp = Enum.reduce(Map.values(new_xps), 0, fn amount, acc -> acc + amount end)

    {highlighted_xps, more_xps} = Enum.split(xps, 10)

    last_day_coded = Enum.at(days_coded, 0)
    xp_per_day = case last_day_coded do
      nil -> 0
      _ -> trunc(Float.round(total_xp / Enum.count(days_coded)))
    end

    conn
    |> assign(:title, user.username)
    |> assign(:user, user)
    |> assign(:total_xp, total_xp)
    |> assign(:last_day_coded, last_day_coded)
    |> assign(:xp_per_day, xp_per_day)
    |> assign(:xps, highlighted_xps)
    |> assign(:more_xps, more_xps)
    |> assign(:new_xps, new_xps)
    |> assign(:machine_xps, machine_xps)
    |> assign(:new_machine_xps, new_machine_xps)
    |> assign(:total_new_xp, total_new_xp)
    |> render("profile.html")
  end

  # Get all XP accumulated in the last 12 hours
  defp get_latest_xps(user, then) do
    xps_q = from x in XP,
      join: p in Pulse, on: p.id == x.pulse_id,
      join: l in Language, on: l.id == x.language_id,
      where: p.user_id == ^user.id and p.sent_at >= ^then,
      select: {x.amount, l.name}

    case Repo.all(xps_q) do
      nil -> %{}
      ret ->
        Enum.reduce(ret, %{}, fn {xp, language}, acc ->
          amount = Map.get(acc, language, 0) + xp
          Map.put(acc, language, amount)
        end)
    end
  end

  # Get all XP per machine and XP per machine per last 12 hours
  defp get_machine_xps(user, then) do
    xps_q = from m in Machine,
      join: p in Pulse, on: m.id == p.machine_id,
      join: x in XP, on: p.id == x.pulse_id,
      where: m.user_id == ^user.id,
      group_by: m.id,
      order_by: [desc: sum(x.amount)],
      select: {m, sum(x.amount)}

    xps = case Repo.all(xps_q) do
      nil -> []
      ret -> ret
    end

    new_xps_q = from m in Machine,
      join: p in Pulse, on: m.id == p.machine_id,
      join: x in XP, on: p.id == x.pulse_id,
      where: m.user_id == ^user.id and p.sent_at >= ^then,
      group_by: m.id,
      order_by: [desc: sum(x.amount)],
      select: {m, sum(x.amount)}

    new_xps = case Repo.all(new_xps_q) do
      nil -> %{}
      ret ->
        Enum.reduce(ret, %{}, fn {machine, amount}, acc ->
          Map.put(acc, machine.id, amount)
        end)
    end

    {xps, new_xps}
  end

  # Get amount of days when user has coded at least something
  defp get_days_coded(user) do
    days_q = from p in Pulse,
      where: p.user_id == ^user.id,
      group_by: fragment("DATE(?)", p.sent_at),
      select: fragment("DATE(?)", p.sent_at),
      order_by: [desc: fragment("DATE(?)", p.sent_at)]

    case Repo.all(days_q) do
      nil -> []
      ret -> ret
    end
  end

  # Fix the username specified in the URL by converting plus characters to spaces.
  # This is not done by Phoenix for some reason.
  defp fix_url_username(username) do
    String.replace(username, "+", " ")
  end
end
