defmodule CodeStats.Repo.Migrations.UserPrivateProfile do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :private_profile, :boolean, null: false, default: false
    end
  end
end
