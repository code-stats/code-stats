defmodule CodeStats.User do
  use CodeStats.Web, :model

  @null_datetime "1970-01-01T00:00:00Z"

  alias Comeonin.Bcrypt
  alias Ecto.Changeset

  import Ecto.Query, only: [from: 2]

  alias CodeStats.{
    Repo,
    Pulse,
    XP
  }

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :last_cached, Calecto.DateTimeUTC
    field :private_profile, :boolean
    field :cache, :map

    has_many :pulses, Pulse

    timestamps
  end

  @required_fields ~w(username password)
  @optional_fields ~w(email)

  @put_required_fields ~w()
  @put_optional_fields ~w(email private_profile)

  @password_required_fields ~w(password)
  @password_optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:password, &hash_password/1)
    |> put_change(:private_profile, false)
    |> validate_length(:username, min: 1)
    |> validate_length(:username, max: 64)
    |> validate_format(:username, ~r/^[^\/#%?&=+]+$/)
    |> validations()
    |> unique_constraint(:username)
  end

  @doc """
  Create changeset for updating a user's data.
  """
  def updating_changeset(model, params \\ %{}) do
    model
    |> cast(params, @put_required_fields, @put_optional_fields)
    |> validations()
  end

  @doc """
  Create a changeset for changing a user's password.
  """
  def password_changeset(model, params \\ %{}) do
    model
    |> cast(params, @password_required_fields, @password_optional_fields)
    |> update_change(:password, &hash_password/1)
  end

  @doc """
  Calculate and store cached XP values for user.

  If `update_all` is set, all XP is gathered and the whole cache is replaced, not
  just added to. This results in a total recalculation of all the user's XP.
  """
  def update_cached_xps(user, update_all \\ false) do
    last_cached = if not update_all and user.last_cached != nil do
      user.last_cached
    else
      {:ok, datetime} = Calendar.DateTime.Parse.rfc3339_utc(@null_datetime)
      datetime
    end

    # If update_all is given, don't use any previous cache data
    cached_data = case update_all do
      false -> unformat_cache_from_db(user.cache)
      true -> %{
        languages: %{},
        machines: %{},
        dates: %{}
      }
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
    final_cache = %{
      languages: language_data,
      machines: machine_data,
      dates: date_data
    }

    # Persist cache changes
    user
    |> cast(%{cache: format_cache_for_db(final_cache)}, [:cache])
    |> Repo.update!()

    # Finally update the user's last_cached timestamp
    updating_changeset(user, %{})
    |> Changeset.put_change(:last_cached, Calendar.DateTime.now_utc())
    |> Repo.update!()

    # Return the cache data for the caller
    final_cache
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
      dates: dates
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
end
