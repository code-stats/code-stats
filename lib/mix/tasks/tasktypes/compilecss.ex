defmodule CodeStats.BuildTasks.CompileCSS do
  import MBU.TaskUtils
  import CodeStats.FrontendConfs

  def bin(), do: node_bin("node-sass")
  def args(in_file, out_path), do: [
    "--source-map-embed",
    "--output",
    out_path,
    in_file
  ]

  def task(out_path, in_file) do
    # Ensure output path exists
    File.mkdir_p!(out_path)

    bin() |> exec(args(in_file, out_path)) |> listen()

    # Output file is input file where extension is changed
    out_file = Path.basename(in_file, "scss") <> "css"

    print_size(Path.join(out_path, out_file))
  end
end
