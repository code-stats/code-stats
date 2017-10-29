defmodule CodeStats.UserTest do
  use CodeStats.DatabaseCase

  alias CodeStats.User

  @valid_attrs %{email: "some@content", username: "some content", password: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    assert {:ok, _} = Repo.insert(User.changeset(%User{}, @valid_attrs))
  end

  test "changeset with invalid attributes" do
    assert {:error, _} = Repo.insert(User.changeset(%User{}, @invalid_attrs))
  end
end
