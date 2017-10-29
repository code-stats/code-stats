defmodule CodeStatsWeb.PermissionUtils do
  @moduledoc """
  Utility functions related to permissions in the system.
  """

  alias CodeStats.User

  @doc """
  Can the given user access the target's profile? They can if the profile is public or
  if they are the same user as the target user. Use nil as user to signify unauthenticated
  users.
  """
  @spec can_access_profile?(%User{} | nil, %User{}) :: boolean
  def can_access_profile?(user, target) do
    (not target.private_profile) or (user != nil and user.id == target.id)
  end
end
