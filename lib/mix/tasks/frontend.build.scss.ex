defmodule Mix.Tasks.Frontend.Build.Scss do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Build the SCSS sources"

  def sass_args() do
    [
      "-o",
      "priv/static/css",
      "--source-map",
      "true",
      "--include-path",
      "node_modules/bootstrap-sass/assets/stylesheets",
      "--precision",
      "8"
    ]
  end

  def scss_file(), do: "web/static/css/app.scss"

  def run(_) do
    exec(
      node_path("/.bin/node-sass"),
      sass_args() ++ [scss_file()]
    ) |> listen()
  end
end
