defmodule Mix.Tasks.Battle.Build.Js.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.MinifyJS

  @shortdoc "Minify built battle mode JS files"
  @preferred_cli_env :prod

  @deps [
    "battle.build.js.bundle"
  ]

  def in_path(), do: Mix.Tasks.Battle.Build.Js.Bundle.out_path()
  def in_file(), do: Path.join([in_path(), "#{battle_prefix()}.js"])

  def out_path(), do: dist_path(battle_prefix(), ["js"])
  def out_file(), do: Path.join([out_path(), "#{battle_prefix()}.js"])

  task _ do
    MinifyJS.task(out_path(), in_file(), out_file())
  end
end
