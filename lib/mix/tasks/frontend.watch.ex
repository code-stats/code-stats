defmodule Mix.Tasks.Frontend.Watch do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Watch frontend and rebuild when necessary"

  def run(_) do
    [
      exec(
        node_path("/.bin/riot"),
        [
          "-w",
          "web/static/riot",
          "priv/static/riot"
        ]
      ),
      exec(
        node_path("/.bin/node-sass"),
        [
          "-o",
          "priv/static/css",
          "--source-map",
          "true",
          "--include-path",
          "node_modules/bootstrap-sass/assets/stylesheets",
          "--precision",
          "8",
          "-w",
          "web/static/css/app.scss"
        ]
      )
    ] |> watch()
  end
end
