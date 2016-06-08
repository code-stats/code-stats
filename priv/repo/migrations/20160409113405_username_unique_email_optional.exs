defmodule CodeStats.Repo.Migrations.UsernameUniqueEmailOptional do
  use Ecto.Migration

  def change do
    # This does not work, `create` was missing.
    # This is here only for posterity.
    #unique_index(:users, [:username])

    alter table(:users) do
      modify(:email, :string, null: true)
    end
  end
end
