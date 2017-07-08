defmodule CodeStats.BuildTasks.MinifyJS do
  import MBU.TaskUtils
  import CodeStats.FrontendConfs

  def bin(), do: node_bin("uglifyjs")
  def args(in_file, out_file) do
    [
      "--in-source-map",
      "#{in_file}.map",
      "--source-map",
      "#{out_file}.map",
      "--source-map-url",
      "#{Path.basename(out_file)}.map",
      "--screw-ie8",
      "-m",
      "-o",
      out_file,
      "--",
      in_file
    ]
  end

  def task(out_path, in_file, out_file) do
    File.mkdir_p!(out_path)

    bin() |> exec(args(in_file, out_file)) |> listen()

    print_size(out_file, in_file)
  end
end
