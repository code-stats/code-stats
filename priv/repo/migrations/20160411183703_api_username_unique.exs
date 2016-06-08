defmodule CodeStats.Repo.Migrations.ApiUsernameUnique do
  use Ecto.Migration

  def change do
    # This does not work and is only here to showcase my mistakes
    #unique_index(:users, [:api_username])
  end
end
