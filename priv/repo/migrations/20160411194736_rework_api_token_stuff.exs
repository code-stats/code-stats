defmodule CodeStats.Repo.Migrations.ReworkApiTokenStuff do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:users, [:api_username])

    alter table(:users) do
      remove :api_username
      remove :api_token

      add :api_salt, :string, null: false, default: ""
    end
  end
end
