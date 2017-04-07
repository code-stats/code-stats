defmodule Mix.Tasks.Frontend.Watch do
  use MBU.BuildTask
  import MBU.TaskUtils
  alias Mix.Tasks.Frontend.Build.Js.Transpile, as: TranspileJS
  alias Mix.Tasks.Frontend.Build.Js.Bundle, as: BundleJS
  alias Mix.Tasks.Frontend.Build.Js.Copy, as: CopyJS
  alias Mix.Tasks.Frontend.Build.Css.Compile, as: CompileCSS
  alias Mix.Tasks.Frontend.Build.Css.Copy, as: CopyCSS
  alias Mix.Tasks.Frontend.Build.Assets, as: Assets

  @shortdoc "Watch frontend and rebuild when necessary"

  @deps [
    "frontend.build"
  ]

  task _ do
    [
      exec(
        TranspileJS.bin(),
        TranspileJS.args() ++ ["-w"]
      ),

      watch(
        "JSBundle",
        TranspileJS.out_path(),
        BundleJS
      ),

      watch(
        "JSCopy",
        BundleJS.out_path(),
        CopyJS
      ),

      watch(
        "CSSCompile",
        CompileCSS.in_path(),
        CompileCSS
      ),

      watch(
        "CSSCopy",
        CompileCSS.out_path(),
        CopyCSS
      ),

      watch(
        "AssetCopy",
        Assets.in_path(),
        Assets
      )
    ]
    |> listen(watch: true)
  end
end
