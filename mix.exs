defmodule CodeStats.Mixfile do
  use Mix.Project

  def project do
    [app: :code_stats,
     version: "1.8.2",
     elixir: "~> 1.4.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {CodeStats, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :comeonin, :calendar, :bamboo]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 1.0.1"},
      {:phoenix_ecto, "~> 3.2.1"},
      {:phoenix_html, "~> 2.9.2"},
      {:phoenix_live_reload, "~> 1.0.6", only: :dev},
      {:gettext, "~> 0.9"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0.1"},
      {:number, "~> 0.5.0"},
      {:earmark, "~> 1.2.0", only: :dev},
      {:ex_doc, "~> 0.15", only: :dev},
      {:calendar, "~> 0.17.2"},
      {:bamboo, "~> 0.8.0"},
      {:corsica, "~> 1.0.0"}
   ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
   ]
  end
end
