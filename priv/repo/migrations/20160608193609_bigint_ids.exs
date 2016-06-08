defmodule CodeStats.Repo.Migrations.BigintIds do
  use Ecto.Migration

  def change do

    alter table(:users) do
      remove :total_xp
    end

    alter table(:xps) do
      modify :id, :bigint
      modify :pulse_id, :bigint
    end

    alter table(:pulses) do
      modify :id, :bigint
    end
  end
end
