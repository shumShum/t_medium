use Mix.Config

config :node_one, NodeOne.Dispatcher,
  polling_interval: 3000

config :node_one, NodeOne.TelegramService,
  url: "https://api.telegram.org/",
  token: System.get_env("TELEGRAM_BOT_TOKEN") || "655692156:AAHhgO1mx0yBoTlO0nMa2DNyxUSciLMCpHU",
  channel_id: System.get_env("TELEGRAM_CHANNEL_ID") || -1001346130646

config :node_one, NodeOne.RabbitService,
  queue_to: "one2two",
  queue_from: "two2one",
  user: "guest",
  password: "guest"