defmodule CodeStats.ProfileController do
  use CodeStats.Web, :controller

  alias CodeStats.{
    AuthUtils,
    PermissionUtils,
    User,
    SetSessionUser,
    ProfileUtils
  }

  def my_profile(conn, _params) do
    user = SetSessionUser.get_user_data(conn)
    redirect(conn, to: profile_path(conn, :profile, user.username))
  end

  def profile(conn, %{"username" => username}) do
    fix_url_username(username)
    |> AuthUtils.get_user(true)
    |> case do
      nil -> render_404(conn)

      %User{} = user ->
        # If username has different capitalisation than actual, redirect to actual
        case username == user.username do
          true ->
            case PermissionUtils.can_access_profile?(AuthUtils.get_current_user(conn), user) do
              true -> render_profile(conn, user)
              false -> render_404(conn)
            end

          false ->
            redirect(conn, to: profile_path(conn, :profile, user.username))
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
    } = User.update_cached_xps(user) |> ProfileUtils.preload_cache_data(user)

    # Calculate total XP
    total_xp = Enum.reduce(language_xps, 0, fn {_, amount}, acc -> acc + amount end)

    # Sort XP data
    language_xps = Enum.sort(language_xps, fn {_, a}, {_, b} -> a > b end)
    machine_xps = Enum.sort(machine_xps, fn {_, a}, {_, b} -> a > b end)
    date_xps = process_date_xps(date_xps)

    # Get new XP data from last 12 hours
    now = DateTime.utc_now()
    latest_xp_since = Calendar.DateTime.subtract!(now, 3600 * ProfileUtils.recent_xp_hours)
    new_language_xps = ProfileUtils.get_language_xps_since(user, latest_xp_since)
    new_machine_xps = ProfileUtils.get_machine_xps_since(user, latest_xp_since)
    total_new_xp = Enum.reduce(Map.values(new_language_xps), 0, fn amount, acc -> acc + amount end)

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
    |> assign(:new_xps, new_language_xps)
    |> assign(:language_xps, language_xps)
    |> assign(:machine_xps, machine_xps)
    |> assign(:new_machine_xps, new_machine_xps)
    |> assign(:total_new_xp, total_new_xp)
    |> render("profile.html")
  end

  defp process_date_xps(date_xps) do
    date_xps
    |> Map.to_list()
    |> Enum.sort(fn {a, _}, {b, _} -> Date.to_erl(a) > Date.to_erl(b) end)
  end

  # Fix the username specified in the URL by converting plus characters to spaces.
  # This is not done by Phoenix for some reason.
  defp fix_url_username(username) do
    String.replace(username, "+", " ")
  end
end
