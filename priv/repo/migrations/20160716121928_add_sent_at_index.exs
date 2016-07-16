defmodule CodeStats.Repo.Migrations.AddSentAtIndex do
  use Ecto.Migration

  def change do
    # This makes "last 12h" searches somewhat faster
    create_if_not_exists index(:pulses, ["sent_at DESC"])
  end
end
