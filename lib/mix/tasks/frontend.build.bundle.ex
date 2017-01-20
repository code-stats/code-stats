defmodule Mix.Tasks.Frontend.Build.Bundle do
  use Mix.Task
  import CodeStats.{TaskUtils, FrontendConfs}

  @shortdoc "Bundle the JavaScript sources into app.js"

  def run(_) do
    run_task("frontend.build.transpile")

    out_path = "#{dist_path()}/js"

    # Browserify won't create output directory automatically
    File.mkdir_p!(out_path)

    exec(
      node_bin("browserify"),
      [
        "--outfile",
        "#{out_path}/app.js",
        "--entry",
        "#{tmp_path()}/transpiled/js/app.js"
      ]
    ) |> listen()
  end
end
