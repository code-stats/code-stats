defmodule CodeStats.XPControllerTest do
  use CodeStats.ConnCase

  alias CodeStats.XP
  @valid_attrs %{amount: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, xp_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    xp = Repo.insert! %XP{}
    conn = get conn, xp_path(conn, :show, xp)
    assert json_response(conn, 200)["data"] == %{"id" => xp.id,
      "pulse_id" => xp.pulse_id,
      "language_id" => xp.language_id,
      "amount" => xp.amount}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, xp_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, xp_path(conn, :create), xp: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(XP, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, xp_path(conn, :create), xp: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    xp = Repo.insert! %XP{}
    conn = put conn, xp_path(conn, :update, xp), xp: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(XP, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    xp = Repo.insert! %XP{}
    conn = put conn, xp_path(conn, :update, xp), xp: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    xp = Repo.insert! %XP{}
    conn = delete conn, xp_path(conn, :delete, xp)
    assert response(conn, 204)
    refute Repo.get(XP, xp.id)
  end
end
