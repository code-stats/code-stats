defmodule Mix.Tasks.Frontend.Watch do
  use MBU.BuildTask
  import MBU.TaskUtils
  import CodeStats.FrontendConfs
  alias Mix.Tasks.Frontend.Build.Js.Transpile, as: FrontendTranspileJS
  alias Mix.Tasks.Frontend.Build.Js.Bundle, as: FrontendBundleJS
  alias Mix.Tasks.Frontend.Build.Js.Copy, as: FrontendCopyJS
  alias Mix.Tasks.Frontend.Build.Css.Compile, as: FrontendCompileCSS
  alias Mix.Tasks.Frontend.Build.Css.Copy, as: FrontendCopyCSS
  alias Mix.Tasks.Frontend.Build.Assets, as: FrontendAssets
  alias Mix.Tasks.Battle.Build.Js.Transpile, as: BattleTranspileJS
  alias Mix.Tasks.Battle.Build.Js.Bundle, as: BattleBundleJS
  alias Mix.Tasks.Battle.Build.Js.Copy, as: BattleCopyJS
  alias Mix.Tasks.Battle.Build.Css.Compile, as: BattleCompileCSS
  alias Mix.Tasks.Battle.Build.Css.Copy, as: BattleCopyCSS

  @shortdoc "Watch frontend assets and rebuild when necessary"

  @deps [
    "frontend.build"
  ]

  task _ do
    [
      watch(
        "BundleCommonJS",
        src_path(common_prefix(), ["js"]),
        fn _ ->
          run_tasks([
            FrontendBundleJS,
            BattleBundleJS
          ])
        end
      ),

      watch(
        "TranspileFrontendJS",
        FrontendTranspileJS.in_path(),
        FrontendTranspileJS
      ),

      watch(
        "BundleFrontendJS",
        FrontendBundleJS.in_path(),
        FrontendBundleJS
      ),

      watch(
        "CopyFrontendJS",
        FrontendCopyJS.in_path(),
        FrontendCopyJS
      ),

      watch(
        "CompileFrontendCSS",
        FrontendCompileCSS.in_path(),
        FrontendCompileCSS
      ),

      watch(
        "CopyFrontendCSS",
        FrontendCopyCSS.in_path(),
        FrontendCopyCSS
      ),

      watch(
        "CopyFrontendAssets",
        FrontendAssets.in_path(),
        FrontendAssets
      ),

      watch(
        "TranspileBattleJS",
        BattleTranspileJS.in_path(),
        BattleTranspileJS
      ),

      watch(
        "BundleBattleJS",
        BattleBundleJS.in_path(),
        BattleBundleJS
      ),

      watch(
        "CopyBattleJS",
        BattleCopyJS.in_path(),
        BattleCopyJS
      ),

      watch(
        "CompileBattleCSS",
        BattleCompileCSS.in_path(),
        BattleCompileCSS
      ),

      watch(
        "CopyBattleCSS",
        BattleCopyCSS.in_path(),
        BattleCopyCSS
      )
    ]
    |> listen(watch: true)
  end
end
