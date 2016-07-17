defmodule CodeStats.Repo.Migrations.AddUserCache do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :cache, :jsonb
    end
  end
end
