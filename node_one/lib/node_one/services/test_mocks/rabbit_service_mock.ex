defmodule NodeOne.RabbitService.Mock do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_), do: {:ok, %{queue_to: [], queue_from: [], tester: nil}}

  def handle_cast({:setup_tester, pid}, state),
    do: {:noreply, %{state | tester: pid}}

  def handle_cast({:send, msg}, state) do
    if state.tester, do: send(state.tester, :sended)
    {:noreply, %{state | queue_to: [msg | state.queue_to]}}
  end

  def handle_cast({:receive, msg}, state) do
    NodeOne.Dispatcher.send(msg)
    {:noreply, %{state | queue_from: [msg | state.queue_from]}}
  end

  def handle_call(:queue_to, _, state),
    do: {:reply, state.queue_to, state}

  def setup_tester(pid), do: GenServer.cast(__MODULE__, {:setup_tester, pid})

  def send(msg), do: GenServer.cast(__MODULE__, {:send, msg})

  def queue_to(), do: GenServer.call(__MODULE__, :queue_to)

  def receive(msg), do: GenServer.cast(__MODULE__, {:receive, msg})
end