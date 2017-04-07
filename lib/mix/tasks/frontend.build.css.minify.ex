defmodule Mix.Tasks.Frontend.Build.Css.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Minify built CSS files"
  @preferred_cli_env :prod

  @deps [
    "frontend.build.css.compile"
  ]

  task _ do
    in_file = Mix.Tasks.Frontend.Build.Css.Compile.out_file()
    out_path = Path.join([dist_path(), "css"])
    out_file = Path.join(out_path, "app.css")

    File.mkdir_p!(out_path)

    exec(
      node_bin("cssnano"),
      [
        in_file,
        out_file,
        "--sourcemap",
        Path.join([out_path, "app.css.map"])
      ]
    ) |> listen()

    print_size(out_file, in_file)
  end
end
