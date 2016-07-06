defmodule CodeStats.XP do
  use CodeStats.Web, :model

  schema "xps" do
    field :amount, :integer
    belongs_to :pulse, CodeStats.Pulse
    belongs_to :language, CodeStats.Language

    timestamps
  end

  @required_fields ~w(amount)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
