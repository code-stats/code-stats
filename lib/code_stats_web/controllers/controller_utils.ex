defmodule CodeStatsWeb.ControllerUtils do
  @moduledoc """
  Utility functions for controllers.
  """

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo
  alias CodeStats.User
  alias CodeStats.Machine

  @doc """
  Get list of user's machines.
  """
  @spec get_user_machines(%User{}) :: [%Machine{}]
  def get_user_machines(%User{} = user) do
    query = from m in Machine,
      where: m.user_id == ^user.id,
      order_by: [desc: m.inserted_at]

    Repo.all(query)
  end
end
