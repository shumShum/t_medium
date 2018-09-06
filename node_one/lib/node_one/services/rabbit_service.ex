defmodule NodeOne.RabbitService do
  use GenServer
  use AMQP

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @config Application.get_env(:node_one, __MODULE__)
  @queue_to    @config[:queue_to]
  @user        @config[:user]
  @password    @config[:password]
  @queue_error "#{@queue}_error"

  def init(_) do
    with {:ok, conn} <- Connection.open("amqp://#{@user}:#{@password}@localhost"),
         {:ok, chan} <- Channel.open(conn),
         {:ok, _} <- AMQP.Queue.declare(chan, @queue_to) do
      {:ok, chan}
    else
      {:error, error} -> {:stop, error, []}
    end
  end

  def handle_cast({:send, msg}, chan) do
    case AMQP.Basic.publish(chan, "", @queue_to, msg) do
      :ok -> {:noreply, chan}
      {:error, err} -> {:stop, err, chan}
    end
  end

  def send(msg), do: GenServer.cast(__MODULE__, {:send, msg})
end