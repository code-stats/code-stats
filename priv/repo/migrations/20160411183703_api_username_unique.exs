defmodule CodeStats.Repo.Migrations.ApiUsernameUnique do
  use Ecto.Migration

  def change do
    unique_index(:users, [:api_username])
  end
end
