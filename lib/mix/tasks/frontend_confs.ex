defmodule CodeStats.FrontendConfs do
  @moduledoc """
  Project specific paths and other stuff for Code::Stats frontend.
  """

  @doc """
  Get absolute path to root directory of project.
  """
  def proj_path() do
    Path.expand("../../../", __DIR__)
  end

  @doc """
  Get absolute path to node_modules.
  """
  def node_path() do
    Path.join(proj_path(), "node_modules")
  end

  @doc """
  Get absolute path to binary installed with npm.
  """
  def node_bin(executable), do: Path.join([node_path(), ".bin", executable])

  @doc """
  Get absolute path to source directory for frontend build.
  """
  def src_path(), do: Path.join([proj_path(), "web", "static"])

  @doc """
  Get absolute path to temp directory for build artifacts.
  """
  def tmp_path(), do: Path.join([proj_path(), ".tmp"])

  @doc """
  Get absolute path to target directory for frontend build.
  """
  def dist_path(), do: Path.join([proj_path(), "priv", "static"])
end
