defmodule CodeStats.Repo.Migrations.MakeXpNotNull do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :total_xp, :bigint, null: false
    end
  end
end
