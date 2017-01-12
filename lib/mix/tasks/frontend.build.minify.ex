defmodule Mix.Tasks.Frontend.Build.Minify do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Minify built JS files"

  def run(_) do
    outdir = "priv/static/js"

    exec(
      node_path("/.bin/uglifyjs"),
      [
        "--source-map",
        "#{outdir}/app.min.js.map",
        "--source-map-url",
        "app.min.js.map",
        "--screw-ie8",
        "-m",
        "-o",
        "#{outdir}/app.min.js",
        "--"
      ] ++ Path.wildcard(
        "priv/static/riot/*.js"
      )
    ) |> listen()
  end
end
