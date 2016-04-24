defmodule CodeStats.PulseController do
  use CodeStats.Web, :controller

  @datetime_max_diff 604800

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias Calendar.DateTime

  alias CodeStats.AuthUtils
  alias CodeStats.Repo

  alias CodeStats.Pulse
  alias CodeStats.Language
  alias CodeStats.XP

  def add(conn, %{"coded_at" => timestamp, "xps" => xps}) do
    if not is_list(xps) do
      resp(conn, 400, "Invalid xps format.")
    end

    case do_add(conn, timestamp, xps) do
      :ok ->
        conn
        |> put_status(201)
        |> json(%{"ok" => "Great success!"})

      {:error, :not_found, reason} ->
        resp(conn, 404, reason)

      {:error, :generic, reason} ->
        resp(conn, 400, reason)

      {:error, :internal, reason} ->
        resp(conn, 500, reason)
    end
  end

  defp do_add(conn, timestamp, xps) do
    {user, machine} = AuthUtils.get_api_details(conn)

    with {:ok, %DateTime{} = datetime}  <- parse_timestamp(timestamp),
      :ok                               <- check_datetime_diff(datetime),
      {:ok, %Pulse{} = pulse}           <- create_pulse(user, machine, datetime),
      :ok                               <- create_xps(pulse, xps) do
        :ok
      end
  end

  defp parse_timestamp(timestamp) do
    case DateTime.Parse.rfc3339_utc(timestamp) do
      {:ok, datetime} -> {:ok, datetime}

      {:bad_format, _} -> {:error, :generic, "Invalid coded_at format."}
    end
  end

  defp check_datetime_diff(datetime) do
    {:ok, diff, _, type} = DateTime.diff(DateTime.now_utc(), datetime)

    if type == :after and diff <= @datetime_max_diff do
      :ok
    else
      {:error, :generic, "Invalid date."}
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
      {:error, changeset} -> {:error, :generic, "Could not create pulse: #{inspect changeset.errors}"}
    end
  end

  defp create_xps(pulse, xps) do
    try do
      Enum.each(xps, fn
        %{"language" => language, "xp" => xp} when is_integer(xp) ->
          case create_xp(pulse, language, xp) do
            :ok -> :ok
            {:error, _, reason} -> raise reason
          end
        _ -> raise "Invalid XP format."
      end)
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
        {:ok, _} -> :ok
        {:error, changeset} -> {:error, :generic, "Could not create XP: #{inspect changeset.errors}"}
      end
    end
  end

  defp get_or_create_language(language_name) do
    # Get-create-get to handle race conditions
    get_query = from l in Language,
      where: l.name == ^language_name

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
              nil -> {:error, :internal, "Could not get-create-get language: #{language_name}"}
            end
        end
    end
  end
end
