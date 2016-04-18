defmodule CodeStats.Repo.Migrations.RemoveUserSalt do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :api_salt
    end
  end
end
