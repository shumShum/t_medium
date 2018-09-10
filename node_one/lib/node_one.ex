defmodule NodeOne do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children =
      if Mix.env() != :test do
        [
          worker(NodeOne.Dispatcher, []),
          worker(NodeOne.RabbitService, [])
        ]
      else
        [
          worker(NodeOne.Dispatcher, []),
          worker(NodeOne.TelegramService.Mock, []),
          worker(NodeOne.RabbitService.Mock, [])
        ]
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: NodeOne.Supervisor)
  end
end
