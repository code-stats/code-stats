defmodule CodeStats.Language.XP do
  use Ecto.Schema

  import Ecto.Changeset

  schema "xps" do
    field :amount, :integer
    belongs_to :pulse, CodeStats.User.Pulse
    belongs_to :language, CodeStats.Language

    # Original language can be used to fix alias errors later, it should always use
    # the language that was sent. :language field on the other hand follows aliases
    belongs_to :original_language, CodeStats.Language

    timestamps()
  end

  @doc """
  Creates a changeset based on the `data` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:amount])
    |> validate_required([:amount])
  end
end
