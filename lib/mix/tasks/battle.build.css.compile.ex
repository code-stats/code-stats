defmodule Mix.Tasks.Battle.Build.Css.Compile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.CompileConciseCSS

  @shortdoc "Compile the battle mode Concise CSS sources"

  def in_path(), do: src_path(battle_prefix(), ["css"])
  def in_file(), do: Path.join([in_path(), "#{battle_prefix()}.scss"])

  def out_path(), do: tmp_path(battle_prefix(), ["compiled", "css"])
  def out_file(), do: Path.join([out_path(), "#{battle_prefix()}.css"])

  task _ do
    CompileConciseCSS.task(out_path(), in_file(), out_file())
  end
end
