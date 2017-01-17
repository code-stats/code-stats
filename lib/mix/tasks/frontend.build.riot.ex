defmodule Mix.Tasks.Frontend.Build.Riot do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Build the RiotJS sources"

  def riot_paths(), do: [
    "web/static/riot",
    "priv/static/riot"
  ]

  def run(_) do
    exec(node_path("/.bin/riot"), riot_paths()) |> listen()
  end
end
