defmodule CodeStats.PulseController do
  use CodeStats.Web, :controller

  @datetime_max_diff 604800

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias Calendar.DateTime, as: CDateTime

  alias CodeStats.{
    AuthUtils,
    Repo,
    Pulse,
    Language,
    XP,
    CacheService
  }

  def add(conn, %{"coded_at" => timestamp, "xps" => xps}) do
    if not is_list(xps) do
      resp(conn, 400, %{error: "Invalid xps format."})
    else

      {user, machine} = AuthUtils.get_api_details(conn)

      with {:ok, %DateTime{} = datetime}  <- parse_timestamp(timestamp),
        {:ok, datetime}                   <- check_datetime_diff(datetime),
        {:ok, %Pulse{} = pulse}           <- create_pulse(user, machine, datetime),
        {:ok, inserted_xps}               <- create_xps(pulse, xps),
        :ok                               <- update_caches(inserted_xps)
      do
        conn |> put_status(201) |> json(%{"ok" => "Great success!"})
      else
        {:error, :not_found, reason} ->
          conn |> put_status(404) |> json(%{"error" => reason})

        {:error, :generic, reason} ->
          conn |> put_status(400) |> json(%{"error" => reason})

        {:error, :internal, reason} ->
          conn |> put_status(500) |> json(%{"error" => reason})
      end
    end
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

  defp create_pulse(user, machine, datetime) do
    params = %{"sent_at" => datetime}

    Pulse.changeset(%Pulse{}, params)
    |> Changeset.put_change(:user_id, user.id)
    |> Changeset.put_change(:machine_id, machine.id)
    |> Repo.insert()
    |> case do
      {:ok, %Pulse{} = pulse} -> {:ok, pulse}
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
      params = %{"amount" => xp}

      XP.changeset(%XP{}, params)
      |> Changeset.put_change(:pulse_id, pulse.id)
      |> Changeset.put_change(:language_id, language.id)
      |> Repo.insert()
      |> case do
        {:ok, inserted_xp} ->
          # Set the language so that it can be used in update_caches
          inserted_xp = %{inserted_xp | language: language}
          {:ok, inserted_xp}

        {:error, _} -> {:error, :generic, "Could not create XP because of an unknown issue."}
      end
    end
  end

  defp get_or_create_language(language_name) do
    # Get-create-get to handle race conditions
    get_query = from l in Language,
      where: fragment("LOWER(?)", l.name) == fragment("LOWER(?)", ^language_name)

    case Repo.one(get_query) do
      %Language{} = language -> {:ok, language}

      nil ->
        Language.changeset(%Language{}, %{"name" => language_name})
        |> Repo.insert()
        |> case do
          {:ok, language} -> {:ok, language}

          {:error, _} ->
            case Repo.one(get_query) do
              %Language{} = language -> {:ok, language}
              nil -> {:error, :internal, "Could not get-create-get language because of an unknown issue."}
            end
        end
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
end
