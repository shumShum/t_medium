defmodule NodeOne do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(NodeOne.Dispatcher, []),
      worker(NodeOne.RabbitService, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: NodeOne.Supervisor)
  end
end
