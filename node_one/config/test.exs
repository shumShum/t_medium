use Mix.Config

config :node_one, :telegram_service, NodeOne.TelegramService.Mock

config :node_one, :rabbit_service, NodeOne.RabbitService.Mock

config :node_one, NodeOne.Dispatcher,
  polling_interval: 10_000_000

config :node_one, NodeOne.TelegramService,
  url: "https://api.telegram.org/",
  token: "_token",
  channel_id: -1