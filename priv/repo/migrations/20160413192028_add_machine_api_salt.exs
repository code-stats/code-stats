defmodule CodeStats.Repo.Migrations.AddMachineApiSalt do
  use Ecto.Migration

  def change do
    alter table(:machines) do
      add :api_salt, :string
    end
  end
end
