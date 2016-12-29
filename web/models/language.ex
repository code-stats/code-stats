defmodule CodeStats.Language do
  use CodeStats.Web, :model

  alias CodeStats.{
    Repo
  }

  schema "languages" do
    field :name, :string

    has_many :xps, CodeStats.XP

    # Either a language has many aliases or it is an alias of some other language,
    # it cannot be both.
    # NOTE: Only 1 level of aliases is supported! That is, you cannot form a chain of
    # aliases.
    belongs_to :alias_of, __MODULE__
    has_many :aliases, __MODULE__, foreign_key: :alias_of_id

    timestamps
  end

  @doc """
  Creates a changeset based on the `data` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> unique_constraint(:lower_name)
  end

  @doc """
  Get or create language with the given name.

  Returns ok and the language struct if successful.
  """
  @spec get_or_create(String.t) :: {:ok, %__MODULE__{}} | {:error, :unknown}
  def get_or_create(language_name) do
    # Get-create-get to handle race conditions
    get_query = from l in __MODULE__,
      where: fragment("LOWER(?)", l.name) == fragment("LOWER(?)", ^language_name),
      preload: :alias_of

    case Repo.one(get_query) do
      %__MODULE__{} = language -> {:ok, language}

      nil ->
        changeset(%__MODULE__{}, %{"name" => language_name})
        |> put_assoc(:alias_of, nil)
        |> Repo.insert()
        |> case do
          {:ok, language} -> {:ok, language}

          {:error, _} ->
            case Repo.one(get_query) do
              %__MODULE__{} = language -> {:ok, language}
              nil -> {:error, :unknown}
            end
        end
    end
  end
end
