defmodule Mix.Tasks.Frontend.Build.Assets do
  use Mix.Task
  import CodeStats.{FrontendConfs}

  @shortdoc "Copy other assets to target dir"

  def run(_) do
    File.cp_r!("#{src_path()}/assets", "#{dist_path()}")
  end
end
