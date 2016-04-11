defmodule CodeStats.Repo.Migrations.UserTotalXp do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :total_xp, :bigint, default: 0
    end
  end
end
