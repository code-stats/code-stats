defmodule Mix.Tasks.Frontend.Build do
  use Mix.Task
  import CodeStats.TaskUtils

  @shortdoc "Build the frontend"

  def run(_) do
    run_tasks([
      "frontend.build.riot",
      "frontend.build.scss"
    ])
  end
end
