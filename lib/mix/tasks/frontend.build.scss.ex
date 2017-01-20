defmodule Mix.Tasks.Frontend.Build.Scss do
  use Mix.Task
  import CodeStats.{TaskUtils, FrontendConfs}

  @shortdoc "Build the SCSS sources"

  def sass_args() do
    [
      "-o",
      "#{dist_path()}/css",
      "--source-map",
      "true",
      "--include-path",
      "#{node_path()}/bootstrap-sass/assets/stylesheets",
      "--precision",
      "8"
    ]
  end

  def scss_file(), do: "#{src_path()}/css/app.scss"

  def run(_) do
    exec(
      node_bin("node-sass"),
      sass_args() ++ [scss_file()]
    ) |> listen()
  end
end
