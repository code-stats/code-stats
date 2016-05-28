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

config :code_stats,

  site_name: "Code::Stats",

# Extra HTML that is injected to every page, right before </body>. Useful for analytics scripts.
  analytics_code: """
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'my-googleanalytics-id', 'auto');
  ga('send', 'pageview');
</script>
"""

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
