defmodule CodeStats.Repo.Migrations.AddMachineActiveFlag do
  use Ecto.Migration

  def change do
    alter table(:machines) do
      add :active, :boolean, default: true, null: false
    end
  end
end
