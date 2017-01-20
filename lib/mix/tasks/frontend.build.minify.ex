defmodule Mix.Tasks.Frontend.Build.Minify do
  use Mix.Task
  import CodeStats.{TaskUtils, FrontendConfs}

  @shortdoc "Minify built JS files"

  def run(_) do
    outdir = "#{dist_path()}/js"

    exec(
      node_bin("uglifyjs"),
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
        "#{dist_path()}/riot/*.js"
      )
    ) |> listen()
  end
end
