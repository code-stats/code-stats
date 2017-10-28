defmodule CodeStatsWeb.PreferencesController do
  use CodeStatsWeb, :controller

  alias CodeStats.User
  alias CodeStatsWeb.AuthUtils
  alias CodeStatsWeb.SetSessionUserPlug

  plug :set_title

  def edit(conn, _params) do
    changeset = User.updating_changeset(SetSessionUserPlug.get_user_data(conn))
    conn
    |> common_edit_assigns()
    |> render("preferences.html", changeset: changeset)
  end

  def do_edit(conn, %{"user" => user}) do
    changeset = User.updating_changeset(SetSessionUserPlug.get_user_data(conn), user)
    case AuthUtils.update_user(changeset) do
      %User{} ->
        conn
        |> put_flash(:success, "Preferences updated!")
        |> redirect(to: preferences_path(conn, :edit))

      %Ecto.Changeset{} = error_changeset ->
        conn
        |> common_edit_assigns()
        |> put_flash(:error, "Error updating preferences.")
        |> render("preferences.html", error_changeset: error_changeset)
    end
  end

  def change_password(conn, %{"old_password" => old_password, "new_password" => new_password}) do
    user = SetSessionUserPlug.get_user_data(conn)

    if AuthUtils.check_user_password(user, old_password) do
      password_changeset = User.password_changeset(user, %{password: new_password})
      case AuthUtils.update_user(password_changeset) do
        %User{} ->
          conn
          |> put_flash(:password_success, "Password changed.")
          |> redirect(to: preferences_path(conn, :edit))

        %Ecto.Changeset{} ->
          conn
          |> put_flash(:password_error, "Error changing password.")
          |> redirect(to: preferences_path(conn, :edit))
      end
    else
      conn
      |> put_flash(:password_error, "Old password was wrong!")
      |> redirect(to: preferences_path(conn, :edit))
    end
  end

  def delete(conn, %{"delete_confirmation" => delete}) do
    user = SetSessionUserPlug.get_user_data(conn)

    if delete == "DELETE" do
      case AuthUtils.delete_user(user) do
        true ->
          conn
          |> AuthUtils.unauth_user()
          |> put_flash(:info, "Your user account has been deleted.")
          |> redirect(to: page_path(conn, :index))
        false ->
          conn
          |> put_flash(:delete_error, "There was an error deleting your account.")
          |> redirect(to: preferences_path(conn, :edit))
      end
    else
      conn
      |> put_flash(:delete_error, "Please confirm deletion by typing \"DELETE\" into the input field.")
      |> redirect(to: preferences_path(conn, :edit))
    end
  end

  defp common_edit_assigns(conn) do
    user_data = SetSessionUserPlug.get_user_data(conn)
    conn
    |> assign(:user, user_data)
  end

  defp set_title(conn, _opts) do
    assign(conn, :title, "Preferences")
  end
end
