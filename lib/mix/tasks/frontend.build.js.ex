defmodule Mix.Tasks.Frontend.Build.Js do
  use MBU.BuildTask
  import MBU.TaskUtils

  @shortdoc "Build the frontend JavaScript"

  task _ do
    todo = case System.get_env("MINIFY") do
      "true"  -> "frontend.build.js.minify"
      _       -> "frontend.build.js.copy"
    end

    run_task(todo)
  end
end
