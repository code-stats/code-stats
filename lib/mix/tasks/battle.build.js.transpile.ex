defmodule Mix.Tasks.Battle.Build.Js.Transpile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.TranspileJS

  @shortdoc "Transpile battle mode JS sources to ES5"

  @deps [
    "battle.build.js.bundle"
  ]

  def in_path(), do: Mix.Tasks.Battle.Build.Js.Bundle.out_path()
  def out_path(), do: tmp_path(battle_prefix(), ["transpiled", "js"])

  task _ do
    TranspileJS.task(in_path(), out_path())
  end
end
