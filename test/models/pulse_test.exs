defmodule CodeStats.PulseTest do
  use CodeStats.ModelCase

  alias CodeStats.Pulse

  @valid_attrs %{sent_at: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Pulse.changeset(%Pulse{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Pulse.changeset(%Pulse{}, @invalid_attrs)
    refute changeset.valid?
  end
end
