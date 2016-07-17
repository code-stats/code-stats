defmodule CodeStats.Repo.Migrations.RemoveCachedXps do
  use Ecto.Migration

  def change do
    drop table(:cached_xps)
  end
end
