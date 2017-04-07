defmodule Mix.Tasks.Frontend.Build.Css.Compile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Build the Concise CSS sources"

  def bin(), do: node_bin("concisecss")

  def out_path(), do: Path.join([tmp_path(), "compiled", "css"])
  def out_file(), do: Path.join([out_path(), "app.css"])

  def in_path(), do: Path.join([src_path(), "css"])
  def in_file(), do: Path.join([in_path(), "app.scss"])

  def args(), do: [
    "compile",
    in_file(),
    out_file()
  ]

  task _ do
    # Ensure output path exists
    File.mkdir_p!(out_path())

    bin() |> exec(args()) |> listen()
  end
end
