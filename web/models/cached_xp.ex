defmodule CodeStats.CachedXP do
  @moduledoc """
  Cached XP is precalculated XP for a certain user in a certain language.
  A user should only have one CachedXP per language. These exist to lighten the load on
  the database, so that not all pulses need to be loaded on every request.
  """

  use CodeStats.Web, :model

  schema "cached_xps" do
    field :amount, :integer
    belongs_to :user, CodeStats.User
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
