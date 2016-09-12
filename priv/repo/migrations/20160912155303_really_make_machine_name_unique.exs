defmodule CodeStats.Repo.Migrations.ReallyMakeMachineNameUnique do
  use Ecto.Migration

  def change do
    # ಠ_ಠ
    create unique_index(:machines, [:name, :user_id])
  end
end
