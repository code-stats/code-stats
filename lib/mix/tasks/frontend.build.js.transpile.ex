defmodule Mix.Tasks.Frontend.Build.Js.Transpile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  import MBU.TaskUtils

  @shortdoc "Transpile JS sources to ES5"

  def bin(), do: node_bin("babel")

  def out_path(), do: Path.join([tmp_path(), "transpiled", "js"])

  def args(), do: [
    Path.join([src_path(), "js"]),
    "--out-dir",
    out_path(),
    "--source-maps",
    "inline"
  ]

  task _ do
    bin() |> exec(args()) |> listen()
  end
end
