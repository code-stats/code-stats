defmodule CodeStats.Repo.Migrations.CreateXP do
  use Ecto.Migration

  def change do
    create table(:xps) do
      add :amount, :integer
      add :pulse_id, references(:pulses, on_delete: :nothing)
      add :language_id, references(:languages, on_delete: :nothing)

      timestamps
    end
    create index(:xps, [:pulse_id])
    create index(:xps, [:language_id])

  end
end
