defmodule CodeStatsWeb.MachineController do
  use CodeStatsWeb, :controller

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias CodeStatsWeb.AuthUtils
  alias CodeStatsWeb.ControllerUtils
  alias CodeStats.Repo
  alias CodeStats.User
  alias CodeStats.User.Machine

  def list(conn, _params) do
    {conn, _} = common_assigns(conn)
    changeset = Machine.changeset(%Machine{})

    conn
    |> render("machines.html", changeset: changeset)
  end

  def add(conn, %{"machine" => params}) do
    {conn, user} = common_assigns(conn)
    Machine.changeset(%Machine{}, params)
    |> Changeset.put_change(:user_id, user.id)
    |> create_machine()
    |> case do
      %Machine{} ->
        conn
        |> put_flash(:success, "Machine added successfully.")
        |> redirect(to: machine_path(conn, :list))

      %Changeset{} = changeset ->
        conn
        |> put_flash(:error, "Error adding machine.")
        |> render("machines.html", changeset: changeset)
    end
  end

  def view_single(conn, %{"id" => id}) do
    user = AuthUtils.get_current_user(conn)

    with %Machine{} = machine <- get_machine_or_404(conn, user, id),
      changeset                = Machine.changeset(machine) do
        conn
        |> assign(:machine, machine)
        |> assign(:title, "Machine: #{machine.name}")
        |> render("single_machine.html", changeset: changeset)
      end
  end

  def edit(conn, %{"id" => id, "machine" => params}) do
    user = AuthUtils.get_current_user(conn)

    with %Machine{} = machine <- get_machine_or_404(conn, user, id),
      changeset                = Machine.update_changeset(machine, params),
      %Machine{} = machine    <- edit_machine_or_flash(conn, changeset) do
        conn
        |> assign(:machine, machine)
        |> put_flash(:success, "Machine edited successfully.")
        |> redirect(to: machine_path(conn, :view_single, machine.id))
      end
  end

  def regen_machine_key(conn, %{"id" => id}) do
    user = AuthUtils.get_current_user(conn)

    with %Machine{} = machine <- get_machine_or_404(conn, user, id),
      changeset                = Machine.api_changeset(machine),
      %Machine{} = machine    <- edit_api_key_or_flash(conn, changeset) do
        conn
        |> put_flash(:success, "API key regenerated for machine #{machine.name}.")
        |> redirect(to: machine_path(conn, :list))
      end
  end

  def delete(conn, %{"id" => id}) do
    user = AuthUtils.get_current_user(conn)

    with %Machine{} = machine <- get_machine_or_404(conn, user, id) do
      case delete_machine(machine) do
        true ->
          # Regenerate user's cache in a background process
          Task.start(User, :update_cached_xps, [user, true])

          conn
          |> put_flash(:success, "Machine deleted.")
          |> redirect(to: machine_path(conn, :list))

        false ->
          conn
          |> put_flash(:error, "Machine could not be deleted.")
          |> redirect(to: machine_path(conn, :view_single, machine.id))
      end
    end
  end

  def deactivate(conn, %{"id" => id}) do
    activate_or_deactivate(conn, id, false)
  end

  def activate(conn, %{"id" => id}) do
    activate_or_deactivate(conn, id, true)
  end

  defp activate_or_deactivate(conn, id, active) do
    user = AuthUtils.get_current_user(conn)
    verb = if active, do: "activated", else: "deactivated"

    with %Machine{} = machine <- get_machine_or_404(conn, user, id),
      changeset                = Machine.activation_changeset(machine, %{active: active}),
      %Machine{} = machine    <- edit_machine_or_flash(conn, changeset)
    do
      conn
      |> put_flash(:success, "Machine #{machine.name} #{verb}.")
      |> redirect(to: machine_path(conn, :list))
    end
  end

  defp common_assigns(conn) do
    user = AuthUtils.get_current_user(conn)
    conn = conn
    |> assign(:user, user)
    |> machines_title()
    |> assign(:machines, ControllerUtils.get_user_machines(user))
    {conn, user}
  end

  # Also checks that user is owner of machine
  defp get_machine_or_404(conn, user, id) do
    (from m in Machine,
      where: m.id == ^id and m.user_id == ^user.id)

    |> Repo.one()
    |> case do
      %Machine{} = machine -> machine
      nil ->
        conn
        |> put_status(404)
        |> render(CodeStats.ErrorView, "404.html")
    end
  end

  defp create_machine(changeset) do
    changeset
    |> Repo.insert()
    |> case do
      {:ok, machine} -> machine
      {:error, changeset} -> changeset
    end
  end

  defp edit_api_key_or_flash(conn, changeset) do
    changeset
    |> Repo.update()
    |> case do
      {:ok, machine} -> machine
      {:error, _} ->
        conn
        |> put_flash(:error, "Error regenerating API key.")
        |> redirect(to: machine_path(conn, :list))
    end
  end

  defp edit_machine_or_flash(conn, changeset) do
    changeset
    |> Repo.update()
    |> case do
      {:ok, machine} -> machine
      {:error, changeset} ->
        conn
        |> put_status(500)
        |> put_flash(:error, "Error editing machine.")
        |> render("single_machine.html", changeset: changeset)
    end
  end

  defp delete_machine(machine) do
    case Repo.delete(machine) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp machines_title(conn), do: assign(conn, :title, "Machines")
end
