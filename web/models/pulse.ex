defmodule CodeStats.Pulse do
  use CodeStats.Web, :model

  schema "pulses" do
    field :sent_at, Calecto.DateTimeUTC
    belongs_to :user, CodeStats.User
    belongs_to :machine, CodeStats.Machine

    has_many :xps, CodeStats.XP

    timestamps
  end

  @doc """
  Creates a changeset based on the `data` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:sent_at])
    |> validate_required([:sent_at])
  end
end
