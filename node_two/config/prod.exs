use Mix.Config

config :node_two, NodeTwoWeb.Endpoint,
  url: [host: "localhost", port: 80],
  http: [port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :node_two, NodeTwo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "node_two_prod",
  hostname: "postgres",
  port: 5432,
  pool_size: 15

config :node_two, NodeTwo.Router,
  ssl: false