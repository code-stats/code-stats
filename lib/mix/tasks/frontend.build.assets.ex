defmodule Mix.Tasks.Frontend.Build.Assets do
  use MBU.BuildTask
  import CodeStats.FrontendConfs

  @shortdoc "Copy assets to target dir"

  @deps []

  def in_path(), do: Path.join([src_path(), "assets"])
  def out_path(), do: Path.join([dist_path(), "assets"])

  task _ do
    # Ensure target path exists
    File.mkdir_p!(out_path())

    File.cp_r!(in_path(), out_path())
  end
end
