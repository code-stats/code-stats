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
  def out_file(), do: Path.join([out_path(), "app.js"])

  def args() do
    [
      "--config",
      "rollup.config.js",
      "--input",
      Path.join([Mix.Tasks.Frontend.Build.Js.Transpile.out_path(), "app.js"]),
      "--output",
      out_file(),
      "--format",
      "iife",
      "--sourcemap",
      Path.join([out_path(), "app.js.map"])
    ]
  end

  task _ do
    bin() |> exec(args()) |> listen()

    print_size(out_file())
  end
end
