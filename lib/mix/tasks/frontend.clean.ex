defmodule Mix.Tasks.Frontend.Clean do
  use MBU.BuildTask
  import CodeStats.FrontendConfs

  @shortdoc "Clean build artifacts"

  task _ do
    File.rm_rf!(tmp_path())
    File.rm_rf!(dist_path())
  end
end
