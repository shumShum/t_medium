use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :node_two, NodeTwoWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :node_two, NodeTwo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "vagrant",
  password: "vagrant",
  database: "node_two_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :node_two, :rabbit_service, NodeTwo.RabbitService.Mock
