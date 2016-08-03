defmodule CodeStats.PasswordReset do
  use CodeStats.Web, :model

  import Ecto.Query, only: [from: 2]

  alias CodeStats.{
    User,
    Repo
  }

  # How long a password reset token is active (hours)
  @token_max_life 4

  schema "password_resets" do
    field :token, Ecto.UUID

    # Virtual field that is only used to fetch the correct user
    field :username, :string, virtual: true

    belongs_to :user, User

    timestamps
  end

  @doc """
  Get the maximum life of a password reset token, in hours.
  """
  @spec token_max_life() :: Integer.t
  def token_max_life(), do: @token_max_life

  @doc """
  Creates a changeset based on the `data` and `params`.

  `params` should contain a key :username with the username of the user
  to create reset for.

  If no params are provided, an invalid changeset is returned
  with no validation performed.

  Note that the function returns both the changeset and the user, if found,
  so it can be used when sending the password reset email.
  """
  @spec changeset(%__MODULE__{}, %{}) :: {%Ecto.Changeset{}, %User{} | nil}
  def changeset(data, params \\ %{}) do
    cset = data
    |> cast(params, [:username])
    |> validate_required([:username])
    |> put_change(:token, Ecto.UUID.generate())
    |> unique_constraint(:token)

    case cset.valid? do
      false -> {cset, nil}

      true ->
        username = get_change(cset, :username)

        q = from u in User,
          where: u.username == ^username

        case Repo.one(q) do
          # Invalidate changeset, error message is not shown so it is not needed
          nil -> {add_error(cset, :username, ""), nil}

          %User{} = u ->
            {put_change(cset, :user_id, u.id), u}
        end
    end
  end
end
