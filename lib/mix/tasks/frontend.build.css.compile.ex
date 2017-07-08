defmodule Mix.Tasks.Frontend.Build.Css.Compile do
  use MBU.BuildTask
  import CodeStats.FrontendConfs
  alias CodeStats.BuildTasks.CompileCSS

  @shortdoc "Compile the Concise CSS sources"

  def in_path(), do: src_path(frontend_prefix(), ["css"])
  def in_file(), do: Path.join([in_path(), "#{frontend_prefix()}.scss"])

  def out_path(), do: tmp_path(frontend_prefix(), ["compiled", "css"])
  def out_file(), do: Path.join([out_path(), "#{frontend_prefix()}.css"])

  task _ do
    CompileCSS.task(out_path(), in_file(), out_file())
  end
end
