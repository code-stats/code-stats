defmodule CodeStats.BuildTasks.BundleJS do
  import MBU.TaskUtils
  import CodeStats.FrontendConfs

  def bin(), do: node_bin("rollup")
  def args(in_file, out_file) do
    [
      "--config",
      "rollup.config.js",
      "--input",
      in_file,
      "--output.file",
      out_file,
      "--output.format",
      "iife",
      "--sourcemap",
      "#{out_file}.map"
    ]
  end

  def task(in_file, out_file) do
    bin() |> exec(args(in_file, out_file)) |> listen()

    print_size(out_file)
  end
end
