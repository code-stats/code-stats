defmodule Mix.Tasks.Frontend.Build do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Build the frontend"

  def run(_) do
    run_task("frontend.clean")

    run_tasks([
      "frontend.build.bundle",
      "frontend.build.scss",
      "frontend.build.assets"
    ])
  end
end
