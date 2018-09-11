defmodule NodeOne.RabbitService do
  use GenServer
  use AMQP
  require Logger

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @config Application.get_env(:node_one, __MODULE__)
  @queue_to    @config[:queue_to]
  @queue_from  @config[:queue_from]
  @user        @config[:user]
  @password    @config[:password]

  def init(_), do: init_connection()

  def handle_info({:basic_consume_ok, %{consumer_tag: _}}, chan), do: {:noreply, chan}

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, chan) do
    spawn fn -> consume(chan, tag, payload) end
    {:noreply, chan}
  end

  def handle_cast({:send, msg}, chan) do
    case AMQP.Basic.publish(chan, "", @queue_to, msg) do
      :ok -> {:noreply, chan}
      {:error, err} -> {:stop, err, chan}
    end
  end

  def send(msg), do: GenServer.cast(__MODULE__, {:send, msg})

  defp init_connection() do
    with {:ok, conn} <- Connection.open("amqp://#{@user}:#{@password}@rabbit"),
         {:ok, chan} <- Channel.open(conn),
         {:ok, _} <- AMQP.Queue.declare(chan, @queue_to),
         {:ok, _} <- AMQP.Queue.declare(chan, @queue_from),
         {:ok, _} <- Basic.consume(chan, @queue_from) do
      {:ok, chan}
    else
      error ->
        error |> inspect() |> Logger.error()
        :timer.sleep(1000)
        init_connection()
    end
  end

  defp consume(channel, tag, msg) do
    with :ok <- NodeOne.Dispatcher.send(msg) do
      :ok = Basic.ack channel, tag
    end
  end
end