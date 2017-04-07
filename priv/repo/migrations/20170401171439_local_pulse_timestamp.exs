defmodule CodeStats.Repo.Migrations.LocalPulseTimestamp do
  use Ecto.Migration

  def change do
    alter table(:pulses) do
      add :sent_at_local, :naive_datetime, null: true
      add :tz_offset, :smallint, null: true
    end
  end
end
