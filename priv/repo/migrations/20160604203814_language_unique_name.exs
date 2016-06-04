defmodule CodeStats.Repo.Migrations.LanguageUniqueName do
  use Ecto.Migration

  def change do
    create unique_index(:languages, [:name])
    create unique_index(:languages, ["LOWER(name)"], name: :languages_lower_name_index)
  end
end
