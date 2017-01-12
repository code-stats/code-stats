defmodule Mix.Tasks.Frontend.Build.Riot do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Build the RiotJS sources"

  def run(_) do
    exec(
      node_path("/.bin/riot"),
      [
        "web/static/riot",
        "priv/static/riot"
      ]
    ) |> listen()
  end
end
