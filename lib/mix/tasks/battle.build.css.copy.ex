defmodule Mix.Tasks.Battle.Build.Css.Copy do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.Copy

  @shortdoc "Copy compiled battle CSS to target dir"

  @deps [
    "battle.build.css.compile"
  ]

  def in_path(), do: Mix.Tasks.Battle.Build.Css.Compile.out_path()
  def out_path(), do: dist_path(battle_prefix(), ["css"])

  task _ do
    Copy.task(in_path(), out_path())
  end
end
