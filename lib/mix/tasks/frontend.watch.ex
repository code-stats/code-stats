defmodule Mix.Tasks.Frontend.Watch do
  use Mix.Task
  import CodeStats.TaskUtils
  alias Mix.Tasks.Frontend.Build.{Riot, Scss}

  @shortdoc "Watch frontend and rebuild when necessary"

  def run(_) do
    [
      exec(
        node_path("/.bin/riot"),
        ["-w"] ++ Riot.riot_paths()
      ),
      exec(
        node_path("/.bin/node-sass"),
        Scss.sass_args() ++ [
          "-w",
          Scss.scss_file()
        ]
      )
    ] |> watch()
  end
end
