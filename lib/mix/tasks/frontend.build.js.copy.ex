defmodule Mix.Tasks.Frontend.Build.Js.Copy do
  use MBU.BuildTask
  import CodeStats.FrontendConfs

  @shortdoc "Copy bundled JS to target dir"

  @deps [
    "frontend.build.js.bundle"
  ]

  task _ do
    # Ensure target path exists
    out_path = Path.join([dist_path(), "js"])
    File.mkdir_p!(out_path)

    File.cp_r!(Mix.Tasks.Frontend.Build.Js.Bundle.out_path(), out_path)
  end
end
