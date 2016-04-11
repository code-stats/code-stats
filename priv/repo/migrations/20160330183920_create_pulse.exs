defmodule CodeStats.Repo.Migrations.CreatePulse do
  use Ecto.Migration

  def change do
    create table(:pulses) do
      add :sent_at, :datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:pulses, [:user_id])

  end
end
