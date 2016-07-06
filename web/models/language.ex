defmodule CodeStats.Language do
  use CodeStats.Web, :model

  schema "languages" do
    field :name, :string

    has_many :pulses, CodeStats.Pulse
    has_many :cached_xps, CodeStats.CachedXP

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end
end
