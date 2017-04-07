defmodule Mix.Tasks.Frontend.Build.Css do
  use MBU.BuildTask
  import MBU.TaskUtils

  @shortdoc "Build the frontend CSS"

  task _ do
    todo = case Mix.env() do
      :prod -> "frontend.build.css.minify"
      _     -> "frontend.build.css.copy"
    end

    run_task(todo)
  end
end
