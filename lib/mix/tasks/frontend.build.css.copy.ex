defmodule Mix.Tasks.Frontend.Build.Css.Copy do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.Copy

  @shortdoc "Copy compiled frontend CSS to target dir"

  @deps [
    "frontend.build.css.compile"
  ]

  def in_path(), do: Mix.Tasks.Frontend.Build.Css.Compile.out_path()
  def out_path(), do: dist_path(frontend_prefix(), ["css"])

  task _ do
    Copy.task(in_path(), out_path())
  end
end
