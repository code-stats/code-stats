defmodule CodeStats.Repo.Migrations.CaseInsensitiveUsernames do
  use Ecto.Migration

  def change do
    create unique_index(:users, ["lower(username)"], name: :users_lower_username_index)
  end
end
