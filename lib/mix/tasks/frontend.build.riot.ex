defmodule Mix.Tasks.Frontend.Build.Riot do
  use Mix.Task
  import CodeStats.{TaskUtils, FrontendConfs}

  @shortdoc "Build the RiotJS sources"

  def riot_paths(), do: [
    "#{src_path()}/riot",
    "#{tmp_path()}/compiled/js/riot"
  ]

  def run(_) do
    exec(node_bin("riot"), riot_paths()) |> listen()
  end
end
