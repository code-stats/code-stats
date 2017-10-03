defmodule CodeStats.BuildTasks.MinifyJS do
  import MBU.TaskUtils
  import CodeStats.FrontendConfs

  def bin(), do: node_bin("uglifyjs")
  def args(in_file, out_file) do
    [
      "--source-map",
      "filename='#{out_file}.map',content='#{in_file}.map',url='#{Path.basename(out_file)}.map'",
      "--compress",
      "--mangle",
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
