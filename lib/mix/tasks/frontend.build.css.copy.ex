defmodule Mix.Tasks.Frontend.Build.Css.Copy do
  use MBU.BuildTask
  import CodeStats.FrontendConfs

  @shortdoc "Copy compiled CSS to target dir"

  @deps [
    "frontend.build.css.compile"
  ]

  task _ do
    # Ensure target path exists
    out_path = Path.join([dist_path(), "css"])
    File.mkdir_p!(out_path)

    File.cp_r!(Mix.Tasks.Frontend.Build.Css.Compile.out_path(), out_path)
  end
end
