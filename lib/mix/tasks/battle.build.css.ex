defmodule Mix.Tasks.Battle.Build.Css do
  use MBU.BuildTask
  import MBU.TaskUtils

  @shortdoc "Build the battle mode CSS"

  task _ do
    todo = case System.get_env("MINIFY") do
      "true" -> "battle.build.css.minify"
      _      -> "battle.build.css.copy"
    end

    run_task(todo)
  end
end
