defmodule CodeStats.Repo.Migrations.AddAliases do
  use Ecto.Migration

  def change do
    alter table(:languages) do
      add :alias_of_id, references(:languages, on_delete: :nilify_all)
    end

    alter table(:xps) do
      add :original_language_id, references(:languages)
    end

    flush()

    execute("update xps set original_language_id=language_id;")
  end
end
