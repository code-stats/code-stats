defmodule Mix.Tasks.Frontend.Build.Css.Minify do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.MinifyCSS

  @shortdoc "Minify built frontend CSS files"
  @preferred_cli_env :prod

  @deps [
    "frontend.build.css.compile"
  ]

  def in_path(), do: Mix.Tasks.Frontend.Build.Css.Compile.out_path()
  def in_file(), do: Path.join([in_path(), "#{frontend_prefix()}.css"])

  def out_path(), do: dist_path(frontend_prefix(), ["css"])
  def out_file(), do: Path.join([out_path(), "#{frontend_prefix()}.css"])

  task _ do
    MinifyCSS.task(out_path(), in_file(), out_file())
  end
end
