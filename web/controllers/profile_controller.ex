defmodule CodeStats.ProfileController do
  use CodeStats.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias CodeStats.{
    Repo,
    AuthUtils,
    PermissionUtils,
    User,
    SetSessionUser,
    Pulse,
    XP,
    Language,
    Machine
  }

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
    # Update and get user's cache data
    %{
      languages: language_xps,
      machines: machine_xps,
      dates: date_xps
    } = User.update_cached_xps(user)

    # Calculate total XP
    total_xp = Map.to_list(language_xps)
    |> Enum.reduce(0, fn {_, amount}, acc -> acc + amount end)

    # Fetch necessary language and machine objects for cached data and sort them
    language_xps = process_language_xps(language_xps)
    machine_xps = process_machine_xps(machine_xps, user)
    date_xps = process_date_xps(date_xps)

    # Get new XP data from last 12 hours
    now = DateTime.utc_now()
    latest_xp_since = Calendar.DateTime.subtract!(now, 3600 * 12)
    new_xps = get_latest_xps(user, latest_xp_since)
    new_machine_xps = get_machine_xps(user, latest_xp_since)
    total_new_xp = Enum.reduce(Map.values(new_xps), 0, fn amount, acc -> acc + amount end)

    last_day_coded = case Enum.empty?(date_xps) do
      true -> nil
      _ -> date_xps |> Enum.at(0) |> elem(0)
    end

    xp_per_day = case last_day_coded do
      nil -> 0
      _ -> trunc(Float.round(total_xp / Enum.count(date_xps)))
    end

    conn
    |> assign(:title, user.username)
    |> assign(:user, user)
    |> assign(:total_xp, total_xp)
    |> assign(:last_day_coded, last_day_coded)
    |> assign(:xp_per_day, xp_per_day)
    |> assign(:new_xps, new_xps)
    |> assign(:language_xps, language_xps)
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
    new_xps_q = from m in Machine,
      join: p in Pulse, on: m.id == p.machine_id,
      join: x in XP, on: p.id == x.pulse_id,
      where: m.user_id == ^user.id and p.sent_at >= ^then,
      group_by: m.id,
      order_by: [desc: sum(x.amount)],
      select: {m, sum(x.amount)}

    case Repo.all(new_xps_q) do
      nil -> %{}
      ret ->
        Enum.reduce(ret, %{}, fn {machine, amount}, acc ->
          Map.put(acc, machine.id, amount)
        end)
    end
  end

  defp process_language_xps(language_xps) do
    language_xps = Map.to_list(language_xps)
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)

    language_ids = Enum.map(language_xps, fn {id, _} -> id end)

    language_q = from l in Language,
      where: l.id in ^language_ids,
      select: {l.id, l}

    languages = Repo.all(language_q) |> Map.new()

    Enum.map(language_xps, fn {id, amount} ->
      {Map.get(languages, id), amount}
    end)
  end

  defp process_machine_xps(machine_xps, user) do
    machine_xps = Map.to_list(machine_xps)
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)

    machine_q = from m in Machine,
      where: m.user_id == ^user.id,
      select: {m.id, m}

    machines = Repo.all(machine_q) |> Map.new()

    Enum.map(machine_xps, fn {id, amount} ->
      {Map.get(machines, id), amount}
    end)
  end

  defp process_date_xps(date_xps) do
    date_xps
    |> Map.to_list()
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)
  end

  # Fix the username specified in the URL by converting plus characters to spaces.
  # This is not done by Phoenix for some reason.
  defp fix_url_username(username) do
    String.replace(username, "+", " ")
  end
end
