defmodule Mix.Tasks.Frontend.Build.Js.Bundle do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Bundle the JavaScript sources into app.js"

  @deps [
    "frontend.build.js.transpile"
  ]

  def bin(), do: node_bin("rollup")

  def out_path(), do: Path.join([tmp_path(), "bundled", "js"])

  def args() do
    op = out_path()

    [
      "--config",
      "rollup.config.js",
      "--input",
      Path.join([Mix.Tasks.Frontend.Build.Js.Transpile.out_path(), "app.js"]),
      "--output",
      Path.join([op, "app.js"]),
      "--format",
      "cjs",
      "--sourcemap",
      Path.join([op, "app.js.map"])
    ]
  end

  task _ do
    bin() |> exec(args()) |> listen()
  end
end
