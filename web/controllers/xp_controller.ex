defmodule CodeStats.XPController do
  use CodeStats.Web, :controller

  alias CodeStats.XP

  plug :scrub_params, "xp" when action in [:create, :update]

  def create(conn, %{"xp" => xp_params}) do
    changeset = XP.changeset(%XP{}, xp_params)

    case Repo.insert(changeset) do
      {:ok, xp} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", xp_path(conn, :show, xp))
        |> render("show.json", xp: xp)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeStats.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def get(conn, _params) do
    conn
    |> send_resp(200, "Peekaboo!")
  end
end
