defmodule CodeStats.Repo.Migrations.AddApiToken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_username, :text, null: false, default: ""
      add :api_token, :text, null: false, default: ""

      modify :username, :string, null: false
      modify :password, :string, null: false
    end
  end
end
