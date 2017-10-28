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
    Path.join([proj_path(), "assets", "node_modules"])
  end

  @doc """
  Get absolute path to binary installed with npm.
  """
  def node_bin(executable), do: Path.join([node_path(), ".bin", executable])

  @doc """
  Get absolute path to source directory for frontend builds.
  """
  def base_src_path(), do: Path.join([proj_path(), "assets"])

  @doc """
  Get absolute path to temp directory for build artifacts.
  """
  def base_tmp_path(), do: Path.join([proj_path(), ".tmp"])

  @doc """
  Get absolute path to target directory for frontend build.
  """
  def base_dist_path(), do: Path.join([proj_path(), "priv", "static"])

  def common_prefix(), do: "common"
  def frontend_prefix(), do: "frontend"
  def battle_prefix(), do: "battle"

  def src_path(prefix, parts \\ []), do: Path.join([base_src_path(), prefix | parts])
  def tmp_path(prefix, parts \\ []), do: Path.join([base_tmp_path(), prefix | parts])
  def dist_path(prefix, parts \\ []), do: Path.join([base_dist_path(), prefix | parts])
end
