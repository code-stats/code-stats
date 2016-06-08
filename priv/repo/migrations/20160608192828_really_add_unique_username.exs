defmodule CodeStats.Repo.Migrations.ReallyAddUniqueUsername do
  use Ecto.Migration

  def change do
    # Shameful display :(
    create unique_index(:users, [:username])
  end
end
