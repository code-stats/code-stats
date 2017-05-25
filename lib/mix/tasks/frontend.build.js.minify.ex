defmodule Mix.Tasks.Frontend.Build.Js.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Minify built JS files"
  @preferred_cli_env :prod

  @deps [
    "frontend.build.js.bundle"
  ]

  def bin(), do: node_bin("uglifyjs")

  def in_path(), do: Mix.Tasks.Frontend.Build.Js.Bundle.out_path()
  def in_file(bundle), do: Path.join([in_path(), bundle <> ".js"])
  def out_path(), do: Path.join([dist_path(), "js"])
  def out_file(bundle), do: Path.join([out_path(), bundle <> ".js"])

  def args(bundle) do
    [
      "--in-source-map",
      Path.join([in_path(), bundle <> ".js.map"]),
      "--source-map",
      Path.join([out_path(), bundle <> ".js.map"]),
      "--source-map-url",
      bundle <> ".js.map",
      "--screw-ie8",
      "-m",
      "-o",
      out_file(bundle),
      "--",
      in_file(bundle)
    ]
  end

  task _ do
    File.mkdir_p!(out_path())

    [
      exec(bin(), args("app")),
      exec(bin(), args("battle"))
    ] |> listen()

    print_size(out_file("app"), in_file("app"))
    print_size(out_file("battle"), in_file("battle"))
  end
end
