defmodule Mix.Tasks.Frontend.Build.Transpile do
  use Mix.Task
  import CodeStats.{TaskUtils, FrontendConfs}

  @shortdoc "Transpile JS sources to ES5"

  def run(_) do
    run_tasks(["frontend.build.riot", "frontend.build.js.copy"])

    exec(
      node_bin("babel"),
      [
        "#{tmp_path()}/compiled/js",
        "--out-dir",
        "#{tmp_path()}/transpiled/js"
      ]
    ) |> listen()
  end
end
