defmodule CodeStats.Repo.Migrations.UniqueUserLanguageCachedXp do
  use Ecto.Migration

  def change do
    unique_index(:cached_xps, [:user_id, :language_id])
  end
end
