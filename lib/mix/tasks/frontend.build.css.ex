defmodule Mix.Tasks.Frontend.Build.Css do
  use MBU.BuildTask
  import MBU.TaskUtils

  @shortdoc "Build the frontend CSS"

  task _ do
    todo = case System.get_env("MINIFY") do
      "true" -> "frontend.build.css.minify"
      _      -> "frontend.build.css.copy"
    end

    run_task(todo)
  end
end
