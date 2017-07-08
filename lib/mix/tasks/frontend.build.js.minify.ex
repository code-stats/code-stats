defmodule Mix.Tasks.Frontend.Build.Js.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.MinifyJS

  @shortdoc "Minify built JS files"
  @preferred_cli_env :prod

  @deps [
    "frontend.build.js.transpile"
  ]

  def in_path(), do: Mix.Tasks.Frontend.Build.Js.Bundle.out_path()
  def in_file(), do: Path.join([in_path(), "#{frontend_prefix()}.js"])

  def out_path(), do: dist_path(frontend_prefix(), ["js"])
  def out_file(), do: Path.join([out_path(), "#{frontend_prefix()}.js"])

  task _ do
    MinifyJS.task(out_path(), in_file(), out_file())
  end
end
