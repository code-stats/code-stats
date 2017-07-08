defmodule Mix.Tasks.Battle.Build.Css.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.MinifyCSS

  @shortdoc "Minify built battle CSS files"
  @preferred_cli_env :prod

  @deps [
    "battle.build.css.compile"
  ]

  def in_path(), do: Mix.Tasks.Battle.Build.Css.Compile.out_path()
  def in_file(), do: Path.join([in_path(), "#{battle_prefix()}.css"])

  def out_path(), do: dist_path(battle_prefix(), ["css"])
  def out_file(), do: Path.join([out_path(), "#{battle_prefix()}.css"])

  task _ do
    MinifyCSS.task(out_path(), in_file(), out_file())
  end
end
