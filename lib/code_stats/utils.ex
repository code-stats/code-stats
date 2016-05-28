defmodule CodeStats.Utils do
  @moduledoc """
  Contains non-Phoenix-specific utilities that don't fit anywhere else.
  """

  @doc """
  Get configuration setting.

  Uses Application.get_env to get the given setting's value.
  """
  @spec get_conf(atom) :: any
  def get_conf(key) do
    Application.get_env(:code_stats, key)
  end
end
