defmodule Mix.Tasks.Frontend.Build.Scss do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Build the SCSS sources"

  def run(_) do
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
        "web/static/css/app.scss"
      ]
    ) |> listen()
  end
end
