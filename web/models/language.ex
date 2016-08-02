defmodule CodeStats.Language do
  use CodeStats.Web, :model

  schema "languages" do
    field :name, :string

    has_many :pulses, CodeStats.Pulse

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
  end
end
