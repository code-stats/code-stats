defmodule CodeStats.User do
  use CodeStats.Web, :model
  alias Comeonin.Bcrypt

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :total_xp, :integer

    field :api_salt, :string

    timestamps
  end

  @required_fields ~w(username password)
  @optional_fields ~w(email)

  @put_required_fields ~w()
  @put_optional_fields ~w(email)

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
    |> put_change(:total_xp, 0)
    |> put_change(:api_salt, generate_api_salt())
    |> validate_length(:username, min: 1)
    |> validate_length(:username, max: 64)
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

  def api_salt_changeset(model, params \\ :empty) do
    model
    |> cast(params, [], [])
    |> put_change(:api_salt, generate_api_salt())
  end

  defp generate_api_salt() do
    Bcrypt.gen_salt()
  end

  defp hash_password(password) do
    Bcrypt.hashpwsalt(password)
  end

  defp validations(changeset) do
    changeset
    |> validate_format(:email, ~r/^$|@/)
  end
end
