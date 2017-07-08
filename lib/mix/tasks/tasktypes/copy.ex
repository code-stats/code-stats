defmodule CodeStats.BuildTasks.Copy do
  def task(from, to) do
    File.mkdir_p!(to)

    File.cp_r!(from, to)
  end
end
