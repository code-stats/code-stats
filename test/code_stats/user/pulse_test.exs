defmodule CodeStats.User.PulseTest do
  use CodeStats.DatabaseCase

  alias CodeStats.User.Pulse

  @valid_attrs %{sent_at: "2010-04-17 14:00:00",
                 sent_at_local: "2010-04-17 14:00:00",
                 tz_offset: "0"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    assert {:ok, _} = Repo.insert(Pulse.changeset(%Pulse{}, @valid_attrs))
  end

  test "changeset with invalid attributes" do
    assert {:error, _} = Repo.insert(Pulse.changeset(%Pulse{}, @invalid_attrs))
  end
end
