defmodule Mix.Tasks.Frontend.Build.Css.Compile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.CompileCSS

  @shortdoc "Compile the SCSS sources"

  def in_path(), do: src_path(frontend_prefix(), ["css"])
  def in_file(), do: Path.join([in_path(), "#{frontend_prefix()}.scss"])

  def out_path(), do: tmp_path(frontend_prefix(), ["compiled", "css"])

  task _ do
    CompileCSS.task(out_path(), in_file())
  end
end
