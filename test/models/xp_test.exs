defmodule CodeStats.XPTest do
  use CodeStats.ModelCase

  alias CodeStats.XP

  @valid_attrs %{amount: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = XP.changeset(%XP{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = XP.changeset(%XP{}, @invalid_attrs)
    refute changeset.valid?
  end
end
