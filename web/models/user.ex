defmodule CodeStats.User do
  use CodeStats.Web, :model

  @null_datetime "1970-01-01T00:00:00Z"

  alias Comeonin.Bcrypt
  alias Ecto.Changeset

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo
  alias CodeStats.Pulse
  alias CodeStats.Language
  alias CodeStats.XP
  alias CodeStats.CachedXP

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :last_cached, Calecto.DateTimeUTC
    field :private_profile, :boolean

    has_many :pulses, Pulse
    has_many :cached_xps, CachedXP

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
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:password, &hash_password/1)
    |> put_change(:private_profile, false)
    |> validate_length(:username, min: 1)
    |> validate_length(:username, max: 64)
    |> validate_format(:username, ~r/^[^\/#%?&=]+$/)
    |> validations()
    |> unique_constraint(:username)
  end

  @doc """
  Create changeset for updating a user's data.
  """
  def updating_changeset(model, params \\ :empty) do
    model
    |> cast(params, @put_required_fields, @put_optional_fields)
    |> validations()
  end

  @doc """
  Create a changeset for changing a user's password.
  """
  def password_changeset(model, params \\ :empty) do
    model
    |> cast(params, @password_required_fields, @password_optional_fields)
    |> update_change(:password, &hash_password/1)
  end

  @doc """
  Calculate and store CachedXP values for user.

  Will first load all existing CachedXP, then sum any new XPs per Language and add those to
  the CachedXPs, creating new ones if required.
  """
  def update_cached_xps(user) do
    last_cached = if user.last_cached != nil do
      user.last_cached
    else
      {:ok, datetime} = Calendar.DateTime.Parse.rfc3339_utc(@null_datetime)
      datetime
    end

    cached_xps_q = from cx in CachedXP,
      where: cx.user_id == ^user.id,
      preload: [:language]

    cached_xps = case Repo.all(cached_xps_q) do
      nil -> []
      ret -> ret
    end
    |> Enum.reduce(%{}, fn cached_xp, acc ->
      # Each cached XP is inserted into a 3-tuple of {CachedXP, dirty bit, amount}
      # The dirty bit is used to persist only changed CachedXPs
      Map.put(acc, cached_xp.language_id, {cached_xp, false, cached_xp.amount})
    end)

    # Load all of user's XPs plus the Language for each XP
    xps_q = from x in XP,
      join: p in Pulse, on: p.id == x.pulse_id,
      join: l in Language, on: l.id == x.language_id,
      where: p.user_id == ^user.id and p.sent_at >= ^last_cached,
      select: {x, l}

    xps = case Repo.all(xps_q) do
      nil -> []
      ret -> ret
    end

    # Reduce over all new xps
    updated_cached_xps = Enum.reduce(xps, cached_xps, fn {xp, language}, cached_xps ->
      {cached_xp, _, amount} = Map.get(
        cached_xps,
        xp.language_id,
        {
          %CachedXP{
            language: language,
            language_id: language.id,
            user_id: user.id,
            amount: 0
          },
          true,
          0
        }
      )

      Map.put(cached_xps, xp.language_id, {cached_xp, true, amount + xp.amount})
    end)
    |> Map.values()

    # Persist changed (dirty) cached XPs
    updated_cached_xps
    |> Enum.filter(fn {_, dirty, _} -> dirty end)
    |> Enum.each(fn {cached_xp, _, amount} ->
      CachedXP.changeset(cached_xp, %{"amount" => amount})
      |> Changeset.put_change(:language_id, cached_xp.language_id)
      |> Changeset.put_change(:user_id, user.id)
      |> Repo.insert_or_update!()
    end)

    # Finally update the user's last_cached timestamp
    updating_changeset(user, %{})
    |> Changeset.put_change(:last_cached, Calendar.DateTime.now_utc())
    |> Repo.update()

    # Return all of the user's cached XPs
    updated_cached_xps
    |> Enum.map(fn
      {cached_xp, false, _} -> cached_xp
      {cached_xp, true, amount} -> %{cached_xp | amount: amount}
    end)
  end

  defp hash_password(password) do
    Bcrypt.hashpwsalt(password)
  end

  defp validations(changeset) do
    changeset
    |> validate_format(:email, ~r/^$|@/)
  end
end
