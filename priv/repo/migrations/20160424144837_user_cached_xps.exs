defmodule CodeStats.Repo.Migrations.UserCachedXps do
  use Ecto.Migration

  def change do
    create table(:cached_xps) do
      add :amount, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :language_id, references(:languages, on_delete: :nothing)

      timestamps
    end
    create index(:cached_xps, [:user_id])
    create index(:cached_xps, [:language_id])

    alter table(:users) do
      add :last_cached, :datetime
    end
  end
end
