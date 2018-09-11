defmodule NodeTwo.RabbitService do
  use GenServer
  use AMQP
  require Logger

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @config Application.get_env(:node_two, __MODULE__)
  @queue_to    @config[:queue_to]
  @queue_from  @config[:queue_from]
  @user        @config[:user]
  @password    @config[:password]

  def init(_) do
    with {:ok, conn} <- Connection.open("amqp://#{@user}:#{@password}@rabbit"),
         {:ok, chan} <- Channel.open(conn),
         {:ok, _} <- AMQP.Queue.declare(chan, @queue_to),
         {:ok, _} <- AMQP.Queue.declare(chan, @queue_from),
         {:ok, _} = Basic.consume(chan, @queue_from) do
      {:ok, chan}
    else
      {:error, error} -> {:stop, error, []}
    end
  end

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

  defp consume(channel, tag, payload) do
    with %{"text" => text, "date" => date} <- payload |> Poison.decode!(),
         {:ok, _} <- NodeTwo.Message.create(text, date) do
      :ok = Basic.ack channel, tag
    end
  end
end