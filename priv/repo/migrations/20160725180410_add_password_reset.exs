defmodule CodeStats.Repo.Migrations.AddPasswordReset do
  use Ecto.Migration

  def change do
    create table(:password_resets) do
      add :token, :uuid
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps
    end

    create index(:password_resets, [:user_id])
    create unique_index(:password_resets, [:token])
  end
end
