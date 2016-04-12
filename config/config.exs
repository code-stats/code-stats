# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :code_stats, CodeStats.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "gWdaZrx0+CB8iuwoC1LMNUD2Lp37PCqvv73Dgid6k+jESaQFWguzrf2hDAoIYE4U",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: CodeStats.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :comeonin,
  bcrypt_log_rounds: 12

config :number,
  delimiter: [
    precision: 0,
    delimiter: ",",
    separator: "."
  ]
