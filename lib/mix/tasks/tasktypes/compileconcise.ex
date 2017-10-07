defmodule CodeStats.BuildTasks.CompileConciseCSS do
  import MBU.TaskUtils
  import CodeStats.FrontendConfs

  def bin(), do: node_bin("concisecss")
  def args(in_file, out_file), do: ["compile", in_file, out_file]

  def task(out_path, in_file, out_file) do
    # Ensure output path exists
    File.mkdir_p!(out_path)

    bin() |> exec(args(in_file, out_file)) |> listen()

    print_size(out_file)
  end
end
