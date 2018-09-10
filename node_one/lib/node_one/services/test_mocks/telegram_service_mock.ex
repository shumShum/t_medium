defmodule NodeOne.TelegramService.Mock do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_), do: {:ok, %{received: [], sended: [], tester: nil}}

  def handle_cast({:setup_tester, pid}, state),
    do: {:noreply, %{state | tester: pid}}

  def handle_cast({:send, msg}, state) do
    if state.tester, do: send(state.tester, :sended)
    {:noreply, %{state | sended: [msg | state.sended]}}
  end

  def handle_cast({:receive, msg}, state),
    do:
      {:noreply,
       %{state | received: [%{text: msg, date: :os.system_time(:millisecond)} | state.received]}}

  def handle_call(:sended, _, state),
    do: {:reply, state.sended, state}

  def handle_call({:updates, date}, _, state),
    do: {:reply, {:ok, state.received |> Enum.filter(&(&1.date > date))}, state}

  def setup_tester(pid), do: GenServer.cast(__MODULE__, {:setup_tester, pid})

  def check(), do: :ok

  def updates(date \\ 0), do: GenServer.call(__MODULE__, {:updates, date})

  def send(msg), do: GenServer.cast(__MODULE__, {:send, msg})

  def sended(), do: GenServer.call(__MODULE__, :sended)

  def receive(msg), do: GenServer.cast(__MODULE__, {:receive, msg})
end
