defmodule Mix.Tasks.Frontend.Build.Css.Compile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Build the Concise CSS sources"

  def bin(), do: node_bin("concisecss")

  def out_path(), do: Path.join([tmp_path(), "compiled", "css"])
  def out_file(bundle), do: Path.join([out_path(), bundle <> ".css"])

  def in_path(), do: Path.join([src_path(), "css"])
  def in_file(bundle), do: Path.join([in_path(), bundle <> ".scss"])

  def args(bundle), do: [
    "compile",
    in_file(bundle),
    out_file(bundle)
  ]

  task _ do
    # Ensure output path exists
    File.mkdir_p!(out_path())

    [
      exec(bin(), args("app")),
      exec(bin(), args("battle"))
    ] |> listen()

    print_size(out_file("app"))
    print_size(out_file("battle"))
  end
end
