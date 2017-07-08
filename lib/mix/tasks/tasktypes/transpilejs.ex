defmodule CodeStats.BuildTasks.TranspileJS do
  import MBU.TaskUtils
  import CodeStats.FrontendConfs

  def bin(), do: node_bin("babel")
  def args(in_path, out_path), do: [
    in_path,
    "--out-dir",
    out_path,
    "--source-maps"
  ]

  def task(in_path, out_path) do
    bin() |> exec(args(in_path, out_path)) |> listen()
  end
end
