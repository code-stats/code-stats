defmodule Mix.Tasks.Frontend.Build.Assets do
  use MBU.BuildTask
  import CodeStats.FrontendConfs

  @shortdoc "Copy assets to target dir"

  @deps []

  def in_path(), do: Path.join([src_path(), "assets"])

  task _ do
    # Ensure target path exists
    File.mkdir_p!(dist_path())

    File.cp_r!(in_path(), dist_path())
  end
end
