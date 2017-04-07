defmodule Mix.Tasks.Frontend.Build do
  use MBU.BuildTask
  import MBU.TaskUtils

  @shortdoc "Build the frontend"

  @deps [
    "frontend.clean"
  ]

  task _ do
    run_tasks([
      "frontend.build.js",
      "frontend.build.css",
      "frontend.build.assets"
    ])
  end
end
