defmodule Mix.Tasks.Frontend.Build.Js.Copy do
  use Mix.Task
  import CodeStats.{FrontendConfs}

  @shortdoc "Copy JavaScript files to babel source dir"

  def run(_) do
    out_path = "#{tmp_path()}/compiled/js"

    File.mkdir_p!(out_path)
    File.cp_r!("#{src_path()}/js", out_path)
  end
end
