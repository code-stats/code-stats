defmodule CodeStats.Repo.Migrations.CreateMachine do
  use Ecto.Migration

  def change do
    create table(:machines) do
      add :name, :string
      add :created_at, :datetime

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps
    end
    create index(:machines, [:user_id])

    unique_index(:machines, [:name, :user_id])
  end
end
