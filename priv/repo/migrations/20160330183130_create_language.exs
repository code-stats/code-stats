defmodule CodeStats.Repo.Migrations.CreateLanguage do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :name, :string

      timestamps
    end

  end
end
