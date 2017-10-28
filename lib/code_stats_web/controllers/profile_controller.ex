defmodule CodeStatsWeb.ProfileController do
  use CodeStatsWeb, :controller

  alias CodeStats.User
  alias CodeStatsWeb.AuthUtils
  alias CodeStatsWeb.PermissionUtils
  alias CodeStatsWeb.ProfileUtils
  alias CodeStatsWeb.SetSessionUser

  def my_profile(conn, _params) do
    user = SetSessionUser.get_user_data(conn)
    redirect(conn, to: profile_path(conn, :profile, user.username))
  end

  def profile(conn, %{"username" => username}) do
    with \
      {:ok, user} <- get_user(username),
      true        <- PermissionUtils.can_access_profile?(AuthUtils.get_current_user(conn), user)
    do
      render_or_redirect(conn, user, username, &render_profile/2, :profile)
    else
      _ ->
        conn
        |> put_status(404)
        |> render(CodeStats.ErrorView, "error_404.html")
    end
  end

  def profile_api(conn, %{"username" => username}) do
    with \
      {:ok, user} <- get_user(username),
      false       <- user.private_profile # Private profiles are not allowed in read API
    do
      render_or_redirect(conn, user, username, &render_profile_api/2, :profile_api)
    else
      _ ->
        conn
        |> put_status(404)
        |> json(%{"error" => "User not found or private."})
    end
  end

  def get_profile_data(user) do
    # Update and get user's cache data
    %{
      languages: language_xps,
      machines: machine_xps,
      dates: date_xps
    } = User.update_cached_xps(user) |> ProfileUtils.preload_cache_data(user)

    # Calculate total XP
    total_xp = Enum.reduce(language_xps, 0, fn {_, amount}, acc -> acc + amount end)

    # Get new XP data from last 12 hours
    now = DateTime.utc_now()
    latest_xp_since = Calendar.DateTime.subtract!(now, 3600 * ProfileUtils.recent_xp_hours)
    new_language_xps = ProfileUtils.get_language_xps_since(user, latest_xp_since)
    new_machine_xps = ProfileUtils.get_machine_xps_since(user, latest_xp_since)
    new_xp = Enum.reduce(Map.values(new_language_xps), 0, fn amount, acc -> acc + amount end)

    {
      total_xp,
      new_xp,
      language_xps,
      new_language_xps,
      machine_xps,
      new_machine_xps,
      date_xps
    }
  end

  def render_profile(conn, user) do
    {
      total_xp,
      new_xp,
      language_xps,
      new_language_xps,
      machine_xps,
      new_machine_xps,
      date_xps
    } = get_profile_data(user)

    dates_list = Map.to_list(date_xps)

    {last_day, _} =
      try do
        Enum.max_by(dates_list, fn {a, _} -> Date.to_erl(a) end)
      rescue
        Enum.EmptyError ->
          {nil, 0}
      end

    xp_per_day = case last_day do
      nil -> 0
      _ -> trunc(Float.round(total_xp / Enum.count(dates_list)))
    end

    conn
    |> assign(:title, user.username)
    |> assign(:user, user)
    |> assign(:total_xp, total_xp)
    |> assign(:last_day_coded, last_day)
    |> assign(:xp_per_day, xp_per_day)
    |> assign(:new_xps, new_language_xps)
    |> assign(:language_xps, language_xps)
    |> assign(:machine_xps, machine_xps)
    |> assign(:new_machine_xps, new_machine_xps)
    |> assign(:total_new_xp, new_xp)
    |> render("profile.html")
  end

  def render_profile_api(conn, user) do
    {
      total_xp,
      new_xp,
      language_xps,
      new_language_xps,
      machine_xps,
      new_machine_xps,
      date_xps
    } = get_profile_data(user)

    # Transform data into JSON serializable formats and combine XPs with
    # recent XPs
    serialize_xps = fn xps, new_xps ->
      xps
      |> Enum.map(fn {key, value} ->
        {key.name, %{"xps" => value, "new_xps" => Map.get(new_xps, key.id, 0)}}
      end)
      |> Map.new()
    end

    serialize_date_xps = fn xps ->
      xps
      |> Map.to_list()
      |> Enum.map(fn {key, value} -> {Date.to_iso8601(key), value} end)
      |> Map.new()
    end

    conn
    |> put_status(200)
    |> json(%{
      "user"      => user.username,
      "total_xp"  => total_xp,
      "new_xp"    => new_xp,
      "languages" => serialize_xps.(language_xps, new_language_xps),
      "machines"  => serialize_xps.(machine_xps, new_machine_xps),
      "dates"     => serialize_date_xps.(date_xps)
    })
  end

  # Render if username matches, redirect otherwise
  defp render_or_redirect(conn, %User{username: username} = user, input_username, renderer, _) when username == input_username do
    renderer.(conn, user)
  end

  defp render_or_redirect(conn, user, _, _, redirect_action) do
    redirect(conn, to: profile_path(conn, redirect_action, user.username))
  end

  # Fix the username specified in the URL by converting plus characters to spaces.
  # This is not done by Phoenix for some reason.
  defp fix_url_username(username) do
    String.replace(username, "+", " ")
  end

  defp get_user(username) do
    with \
      username        <- fix_url_username(username),
      %User{} = user  <- AuthUtils.get_user(username, true)
    do
      {:ok, user}
    else
      _ -> :error
    end
  end
end
