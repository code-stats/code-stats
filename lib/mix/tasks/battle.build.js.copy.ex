defmodule Mix.Tasks.Battle.Build.Js.Copy do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.Copy

  @shortdoc "Copy bundled battle JS to target dir"

  @deps [
    "battle.build.js.transpile"
  ]

  def in_path(), do: Mix.Tasks.Battle.Build.Js.Transpile.out_path()
  def out_path(), do: dist_path(battle_prefix(), ["js"])

  task _ do
    Copy.task(in_path(), out_path())
  end
end
