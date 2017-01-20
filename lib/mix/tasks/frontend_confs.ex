defmodule CodeStats.FrontendConfs do
  import CodeStats.TaskUtils

  @moduledoc """
  Project specific paths and other stuff for CodeStats frontend.
  """

  @doc """
  Get absolute path to node_modules.
  """
  def node_path() do
    "#{proj_path()}/node_modules"
  end

  @doc """
  Get absolute path to binary installed with npm.
  """
  def node_bin(executable), do: "#{node_path()}/.bin/#{executable}"

  @doc """
  Get absolute path to source directory for frontend build.
  """
  def src_path(), do: "#{proj_path()}/web/static"

  @doc """
  Get absolute path to temp directory for build artifacts.
  """
  def tmp_path(), do: "#{proj_path()}/.tmp"

  @doc """
  Get absolute path to target directory for frontend build.
  """
  def dist_path(), do: "#{proj_path()}/priv/static"
end
