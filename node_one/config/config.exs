use Mix.Config

config :node_one, :telegram_service, NodeOne.TelegramService

config :node_one, :rabbit_service, NodeOne.RabbitService

config :node_one, NodeOne.Dispatcher,
  polling_interval: 3000

config :node_one, NodeOne.TelegramService,
  url: "https://api.telegram.org/",
  token: {:system, "TELEGRAM_BOT_TOKEN"},
  channel_id: {:system, "TELEGRAM_CHANNEL_ID"}

config :node_one, NodeOne.RabbitService,
  queue_to: "one2two",
  queue_from: "two2one",
  user: "guest",
  password: "guest"

if Mix.env() == :test, do: import_config("test.exs")