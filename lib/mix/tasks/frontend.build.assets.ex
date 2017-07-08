defmodule Mix.Tasks.Frontend.Build.Assets do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.Copy

  @shortdoc "Copy frontend assets to target dir"

  @deps []

  def in_path(), do: src_path(frontend_prefix(), ["assets"])
  def out_path(), do: dist_path(frontend_prefix(), ["assets"])

  task _ do
    Copy.task(in_path(), out_path())
  end
end
