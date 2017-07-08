defmodule Mix.Tasks.Frontend.Clean do
  use MBU.BuildTask
  import CodeStats.FrontendConfs

  @shortdoc "Clean build artifacts"

  task _ do
    File.rm_rf!(base_tmp_path())
    File.rm_rf!(base_dist_path())
  end
end
