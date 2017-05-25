defmodule Mix.Tasks.Frontend.Build.Css.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils
  alias Mix.Tasks.Frontend.Build.Css.Compile, as: CompileCSS

  @shortdoc "Minify built CSS files"
  @preferred_cli_env :prod

  @deps [
    "frontend.build.css.compile"
  ]

  def bin(), do: node_bin("cssnano")

  def in_file(bundle), do: CompileCSS.out_file(bundle)
  def out_path(), do: Path.join([dist_path(), "css"])
  def out_file(bundle), do: Path.join([out_path(), bundle <> ".css"])

  def args(bundle) do
    [
      in_file(bundle),
      out_file(bundle),
      "--sourcemap"
    ]
  end

  task _ do
    File.mkdir_p!(out_path())

    IO.inspect([bin(), args("app")])

    [
      exec(bin(), args("app")),
      exec(bin(), args("battle"))
    ] |> listen()

    print_size(out_file("app"), in_file("app"))
    print_size(out_file("battle"), in_file("battle"))
  end
end
