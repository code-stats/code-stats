defmodule Mix.Tasks.Frontend.Build.Js.Copy do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.Copy

  @shortdoc "Copy bundled frontend JS to target dir"

  @deps [
    "frontend.build.js.transpile"
  ]

  def in_path(), do: Mix.Tasks.Frontend.Build.Js.Transpile.out_path()
  def out_path(), do: dist_path(frontend_prefix(), ["js"])

  task _ do
    Copy.task(in_path(), out_path())
  end
end
