defmodule CodeStats.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @null_datetime "1970-01-01T00:00:00Z"

  alias Comeonin.Bcrypt

  alias CodeStats.Repo
  alias CodeStats.User.Pulse
  alias CodeStats.XP

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :last_cached, :utc_datetime
    field :private_profile, :boolean
    field :cache, :map

    has_many :pulses, Pulse

    timestamps()
  end

  @doc """
  Creates a changeset based on the `data` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:username, :password, :email])
    |> validate_required([:username, :password])
    |> update_change(:password, &hash_password/1)
    |> put_change(:private_profile, false)
    |> validate_length(:username, min: 1)
    |> validate_length(:username, max: 64)
    |> validate_format(:username, ~r/^[^\/#%?&=+]+$/)
    |> validations()
    |> unique_constraint(:username)
    |> unique_constraint(:lower_username)
  end

  @doc """
  Create changeset for updating a user's data.
  """
  def updating_changeset(data, params \\ %{}) do
    data
    |> cast(params, [:email, :private_profile])
    |> validations()
  end

  @doc """
  Create a changeset for changing a user's password.
  """
  def password_changeset(data, params \\ %{}) do
    data
    |> cast(params, [:password])
    |> validate_required([:password])
    |> update_change(:password, &hash_password/1)
  end

  @doc """
  Calculate and store cached XP values for user.

  If `update_all` is set, all XP is gathered and the whole cache is replaced, not
  just added to. This results in a total recalculation of all the user's XP.
  """
  def update_cached_xps(user, update_all \\ false) do
    update_start_time = DateTime.utc_now()

    last_cached = if not update_all and user.last_cached != nil do
      user.last_cached
    else
      {:ok, datetime} = Calendar.DateTime.Parse.rfc3339_utc(@null_datetime)
      datetime
    end

    # If update_all is given or user cache is empty, don't use any previous cache data
    cached_data = %{
      languages: %{},
      machines: %{},
      dates: %{},
      caching_duration: 0,      # Time taken for the last partial cache update
      total_caching_duration: 0 # Time taken for the last full cache update
    }

    cached_data = case {update_all, user.cache} do
      {true, _} -> cached_data
      {_, nil} -> cached_data
      _ -> unformat_cache_from_db(user.cache)
    end

    # Load all of user's new XP plus required associations
    xps_q = from x in XP,
      join: p in Pulse, on: p.id == x.pulse_id,
      where: p.user_id == ^user.id and p.inserted_at >= ^last_cached,
      select: {p, x}

    xps = case Repo.all(xps_q) do
      nil -> []
      ret -> ret
    end

    language_data = generate_language_cache(cached_data.languages, xps)
    machine_data = generate_machine_cache(cached_data.machines, xps)
    date_data = generate_date_cache(cached_data.dates, xps)

    cache_contents =
      %{
        languages: language_data,
        machines: machine_data,
        dates: date_data
      }

    # Correct key for storing caching duration
    duration_key = if update_all, do: :total_caching_duration, else: :caching_duration

    # Store cache that is formatted for DB and add caching duration
    stored_cache =
      cache_contents
      |> format_cache_for_db()
      |> Map.put(:caching_duration, cached_data.caching_duration)
      |> Map.put(:total_caching_duration, cached_data.total_caching_duration)
      |> Map.put(duration_key, get_caching_duration(update_start_time))

    # Persist cache changes and update user's last cached timestamp
    user
    |> cast(%{cache: stored_cache}, [:cache])
    |> put_change(:last_cached, Calendar.DateTime.now_utc())
    |> Repo.update!()

    # Return the cache data for the caller
    cache_contents
  end

  defp generate_language_cache(language_data, xps) do
    Enum.reduce(xps, language_data, fn {_, xp}, acc ->
      Map.get_and_update(acc, xp.language_id, fn old_val ->
        {old_val, val_or_0(old_val) + xp.amount}
      end)
      |> elem(1)
    end)
  end

  defp generate_machine_cache(machine_data, xps) do
    Enum.reduce(xps, machine_data, fn {pulse, xp}, acc ->
      Map.get_and_update(acc, pulse.machine_id, fn old_val ->
        {old_val, val_or_0(old_val) + xp.amount}
      end)
      |> elem(1)
    end)
  end

  defp generate_date_cache(date_data, xps) do
    Enum.reduce(xps, date_data, fn {pulse, xp}, acc ->
      date = DateTime.to_date(pulse.sent_at)

      Map.get_and_update(acc, date, fn old_val ->
        {old_val, val_or_0(old_val) + xp.amount}
      end)
      |> elem(1)
    end)
  end

  # Format data in cache for storing into db as JSON
  defp format_cache_for_db(cache) do
    languages = Map.get(cache, :languages)
    |> int_keys_to_str()

    machines = Map.get(cache, :machines)
    |> int_keys_to_str()

    dates = Map.get(cache, :dates)
    |> Map.to_list()
    |> Enum.map(fn {key, value} -> {Date.to_iso8601(key), value} end)
    |> Map.new()

    %{
      languages: languages,
      machines: machines,
      dates: dates
    }
  end

  # Unformat data from DB to native datatypes
  defp unformat_cache_from_db(cache) do
    languages = Map.get(cache, "languages")
    |> str_keys_to_int()

    machines = Map.get(cache, "machines")
    |> str_keys_to_int()

    dates = Map.get(cache, "dates")
    |> Map.to_list()
    |> Enum.map(fn {key, value} -> {Date.from_iso8601!(key), value} end)
    |> Map.new()

    %{
      languages: languages,
      machines: machines,
      dates: dates,
      caching_duration: Map.get(cache, "caching_duration", 0),
      total_caching_duration: Map.get(cache, "total_caching_duration", 0)
    }
  end

  defp hash_password(password) do
    Bcrypt.hashpwsalt(password)
  end

  defp validations(changeset) do
    changeset
    |> validate_format(:email, ~r/^$|@/)
  end

  defp val_or_0(nil), do: 0
  defp val_or_0(val) when is_number(val), do: val

  defp int_keys_to_str(map) do
    map
    |> Map.to_list()
    |> Enum.map(fn {key, value} -> {Integer.to_string(key), value} end)
    |> Map.new()
  end

  defp str_keys_to_int(map) do
    map
    |> Map.to_list()
    |> Enum.map(fn {key, value} -> {Integer.parse(key) |> elem(0), value} end)
    |> Map.new()
  end

  defp get_caching_duration(start_time) do
    Calendar.DateTime.diff(DateTime.utc_now(), start_time)
    |> (fn {:ok, s, us, _} -> s + (us / 1_000_000) end).()
  end
end
