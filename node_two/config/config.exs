# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :node_two,
  ecto_repos: [NodeTwo.Repo]

# Configures the endpoint
config :node_two, NodeTwoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "O08T8iEnxKktRMOQUwBBIuzt8pxLuW+sAEK6CirvMVH4bLV5hBkmgVOUaMWCwUwN",
  render_errors: [view: NodeTwoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NodeTwo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

config :node_two, NodeTwo.RabbitService,
  queue_to: "two2one",
  queue_from: "one2two",
  user: "guest",
  password: "guest"