defmodule Mix.Tasks.Frontend.Build.Js.Transpile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.TranspileJS

  @shortdoc "Transpile frontend JS sources to ES5"

  @deps [
    "frontend.build.js.bundle"
  ]

  def in_path(), do: Mix.Tasks.Frontend.Build.Js.Bundle.out_path()
  def out_path(), do: tmp_path(frontend_prefix(), ["transpiled", "js"])

  task _ do
    TranspileJS.task(in_path(), out_path())
  end
end
