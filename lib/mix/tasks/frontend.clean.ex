defmodule Mix.Tasks.Frontend.Clean do
  use Mix.Task
  import CodeStats.{FrontendConfs}

  @shortdoc "Clean build artifacts"

  def run(_) do
    File.rm_rf!(tmp_path())
    File.rm_rf!(dist_path())
  end
end
