defmodule CodeStats do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository first for database access
      supervisor(CodeStats.Repo, []),

      # Start cache service
      # We want this to be before the endpoint so that the caches are ready for new
      # requests
      worker(CodeStats.CacheService, []),

      # Start the endpoint when the application starts
      supervisor(CodeStatsWeb.Endpoint, []),

      # Here you could define other workers and supervisors as children
      # worker(CodeStats.Worker, [arg1, arg2, arg3]),

      # Start XPCacheRefresher
      worker(CodeStats.XPCacheRefresher, []),

      # Start The Terminator
      worker(CodeStats.Terminator, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeStats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CodeStatsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
