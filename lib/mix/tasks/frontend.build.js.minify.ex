defmodule Mix.Tasks.Frontend.Build.Js.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Minify built JS files"
  @preferred_cli_env :prod

  @deps [
    "frontend.build.js.bundle"
  ]

  task _ do
    in_path = Mix.Tasks.Frontend.Build.Js.Bundle.out_path()
    in_file = Path.join([in_path, "app.js"])
    out_path = Path.join([dist_path(), "js"])
    out_file = Path.join([out_path, "app.js"])

    File.mkdir_p!(out_path)

    exec(
      node_bin("uglifyjs"),
      [
        "--in-source-map",
        Path.join([in_path, "app.js.map"]),
        "--source-map",
        Path.join([out_path, "app.js.map"]),
        "--source-map-url",
        "app.js.map",
        "--screw-ie8",
        "-m",
        "-o",
        out_file,
        "--",
        in_file
      ]
    ) |> listen()

    print_size(out_file, in_file)
  end
end
