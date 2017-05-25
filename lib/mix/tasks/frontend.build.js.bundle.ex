defmodule Mix.Tasks.Frontend.Build.Js.Bundle do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Bundle the JavaScript sources into bundles"

  @deps [
    "frontend.build.js.transpile"
  ]

  def bin(), do: node_bin("rollup")

  def out_path(), do: Path.join([tmp_path(), "bundled", "js"])
  def out_file(bundle), do: Path.join([out_path(), bundle <> ".js"])

  def args(bundle) do
    [
      "--config",
      "rollup.config.js",
      "--input",
      Path.join([Mix.Tasks.Frontend.Build.Js.Transpile.out_path(), bundle <> ".js"]),
      "--output",
      out_file(bundle),
      "--format",
      "iife",
      "--sourcemap",
      Path.join([out_path(), bundle <> ".js.map"])
    ]
  end

  task _ do
    [
      exec(bin(), args("app")),
      exec(bin(), args("battle"))
    ] |> listen()

    print_size(out_file("app"))
    print_size(out_file("battle"))
  end
end
