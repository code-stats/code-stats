defmodule CodeStats.Repo.Migrations.UsernameUniqueEmailOptional do
  use Ecto.Migration

  def change do
    unique_index(:users, [:username])

    alter table(:users) do
      modify(:email, :string, null: true)
    end
  end
end
