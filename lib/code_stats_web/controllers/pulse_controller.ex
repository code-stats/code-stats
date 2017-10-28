defmodule CodeStatsWeb.PulseController do
  use CodeStatsWeb, :controller

  @datetime_max_diff 604800
  @rfc3339_offset_regex ~R/(\+|-)(\d{2}):?(\d{2})$/

  alias Ecto.Changeset

  alias Calendar.DateTime, as: CDateTime

  alias CodeStatsWeb.AuthUtils
  alias CodeStatsWeb.GeoIP
  alias CodeStatsWeb.ProfileChannel
  alias CodeStatsWeb.FrontpageChannel
  alias CodeStatsWeb.GeoIP
  alias CodeStats.{
    Repo,
    Pulse,
    Language,
    XP,
    CacheService
  }

  plug GeoIP

  def add(conn, %{"coded_at" => timestamp, "xps" => xps}) when is_list(xps) do
    {user, machine} = AuthUtils.get_api_details(conn)

    with \
      {:ok, %DateTime{} = datetime} <- parse_timestamp(timestamp),
      {:ok, datetime}               <- check_datetime_diff(datetime),
      {:ok, offset}                 <- get_offset(timestamp),
      {:ok, %Pulse{} = pulse}       <- create_pulse(user, machine, datetime, offset),
      {:ok, inserted_xps}           <- create_xps(pulse, xps),
      :ok                           <- update_caches(inserted_xps)
    do
      # Broadcast XP data to possible viewers on profile page and frontpage
      coords = GeoIP.get_coords(conn)
      ProfileChannel.send_pulse(user, %{pulse | xps: inserted_xps})
      FrontpageChannel.send_pulse(user, coords, %{pulse | xps: inserted_xps})

      conn |> put_status(201) |> json(%{ok: "Great success!"})
    else
      {:error, :not_found, reason} ->
        conn |> put_status(404) |> json(%{error: reason})

      {:error, :generic, reason} ->
        conn |> put_status(400) |> json(%{error: reason})

      {:error, :internal, reason} ->
        conn |> put_status(500) |> json(%{error: reason})
    end
  end

  def add(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Invalid xps format."})
  end

  defp parse_timestamp(timestamp) do
    case CDateTime.Parse.rfc3339_utc(timestamp) do
      {:ok, datetime} -> {:ok, datetime}

      {:bad_format, _} -> {:error, :generic, "Invalid coded_at format."}
    end
  end

  defp check_datetime_diff(datetime) do
    {:ok, diff, _, type} = CDateTime.diff(CDateTime.now_utc(), datetime)

    if type == :after and diff <= @datetime_max_diff do
      {:ok, datetime}
    else
      if type == :before or type == :same_time do
        {:ok, CDateTime.now_utc()}
      else
        {:error, :generic, "Invalid date."}
      end
    end
  end

  defp create_pulse(user, machine, datetime, offset) do
    # Create shifted naive datetime from UTC datetime and offset, recreating the user's
    # local time
    local_datetime = CDateTime.add!(datetime, offset * 60) |> CDateTime.to_naive()

    params = %{
      "sent_at" => datetime,
      "tz_offset" => offset,
      "sent_at_local" => local_datetime
    }

    Pulse.changeset(%Pulse{}, params)
    |> Changeset.put_change(:user_id, user.id)
    |> Changeset.put_change(:machine_id, machine.id)
    |> Repo.insert()
    |> case do
      {:ok, %Pulse{} = pulse} ->
        # Set the machine so it can be used later
        pulse = %{pulse | machine: machine}
        {:ok, pulse}
      {:error, _} -> {:error, :generic, "Could not create pulse because of an unknown issue."}
    end
  end

  defp create_xps(pulse, xps) do
    try do
      inserted_xps = Enum.map(xps, fn
        %{"language" => language, "xp" => xp} when is_integer(xp) ->
          case create_xp(pulse, language, xp) do
            {:ok, inserted_xp} -> inserted_xp
            {:error, _, reason} -> raise reason
          end
        _ -> raise "Invalid XP format."
      end)
      {:ok, inserted_xps}
    rescue
      e in RuntimeError -> {:error, :generic, e.message}
    end
  end

  defp create_xp(pulse, language_name, xp) do
    with {:ok, %Language{} = language} <- get_or_create_language(language_name) do

      # If language was an alias of another, use that instead
      final_language = case language.alias_of do
        %Language{} = aliased -> aliased
        nil -> language
      end

      params = %{"amount" => xp}

      XP.changeset(%XP{}, params)
      |> Changeset.put_change(:pulse_id, pulse.id)
      |> Changeset.put_change(:language_id, final_language.id)
      |> Changeset.put_change(:original_language_id, language.id)
      |> Repo.insert()
      |> case do
        {:ok, inserted_xp} ->
          # Set the language so that it can be used later
          inserted_xp = %{inserted_xp | language: final_language}
          {:ok, inserted_xp}

        {:error, _} -> {:error, :generic, "Could not create XP because of an unknown issue."}
      end
    end
  end

  defp get_or_create_language(language_name) do
    case Language.get_or_create(language_name) do
      {:ok, language} -> {:ok, language}
      {:error, :unknown} -> {:error, :internal, "Could not get-create-get language because of an unknown issue."}
    end
  end

  defp update_caches(xps) do
    try do
      Enum.each(xps, fn xp ->
        CacheService.add_total_language_xp(xp.language, xp.amount)
      end)
    rescue
      e in RuntimeError -> {:error, :generic, e.message}
    end
  end

  defp get_offset(timestamp) do
    # Get offset from an RFC3339 or ISO8601 string.
    timestamp = timestamp |> String.trim() |> String.downcase()

    if String.ends_with?(timestamp, "z") do
      {:ok, 0}
    else
      case Regex.run(@rfc3339_offset_regex, timestamp) do
        [_, sign, hours, minutes] -> {:ok, calculate_offset(sign, hours, minutes)}
        _ -> {:error, :generic, "Invalid TZ offset!"}
      end
    end
  end

  defp calculate_offset("+", hours, minutes), do: calculate_offset(hours, minutes)

  defp calculate_offset("-", hours, minutes), do: -calculate_offset(hours, minutes)

  defp calculate_offset(hours, minutes) do
    {hours, _} = Integer.parse(hours)
    {minutes, _} = Integer.parse(minutes)

    hours * 60 + minutes
  end
end
