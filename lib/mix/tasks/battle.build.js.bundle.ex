defmodule Mix.Tasks.Battle.Build.Js.Bundle do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.BundleJS

  @shortdoc "Bundle the battle mode JavaScript sources into bundles"

  def in_path(), do: src_path(battle_prefix(), ["js"])
  def in_file(), do: Path.join([in_path(), "#{battle_prefix()}.js"])

  def out_path(), do: tmp_path(battle_prefix(), ["bundled", "js"])
  def out_file(), do: Path.join([out_path(), "#{battle_prefix()}.js"])

  task _ do
    BundleJS.task(in_file(), out_file())
  end
end
