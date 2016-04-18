defmodule CodeStats.Repo.Migrations.CascadeDeletes do
  use Ecto.Migration

  def change do
    execute "alter table pulses drop constraint pulses_user_id_fkey"

    alter table(:pulses) do
      add :machine_id, references(:machines, on_delete: :delete_all)
      modify :user_id, references(:users, on_delete: :delete_all)
    end

    execute "alter table xps drop constraint xps_pulse_id_fkey"

    alter table(:xps) do
      modify :pulse_id, references(:pulses, on_delete: :delete_all)
    end
  end
end
