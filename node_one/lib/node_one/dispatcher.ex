defmodule NodeOne.Dispatcher do
  use GenServer
  require Logger

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @polling_interval Application.get_env(:node_one, __MODULE__)[:polling_interval]
  @telegram Application.get_env(:node_one, :telegram_service)
  @rabbit Application.get_env(:node_one, :rabbit_service)

  def init(_) do
    case @telegram.check() do
      :ok ->
        Logger.info("Dispatcher started")
        schedule_poll()
        {:ok, %{last_update_date: 0}}

      {:error, error} ->
        Logger.error("Telegram not available: #{inspect(error)}")
        {:stop, error}
    end
  end

  def handle_info(:poll, state) do
    case @telegram.updates(state.last_update_date) do
      {:ok, messages} ->
        for msg <- messages, do: msg |> Poison.encode!() |> @rabbit.send()

        last_update_date =
          case List.last(messages) do
            nil -> state.last_update_date
            msg -> msg.date
          end

        schedule_poll()

        {:noreply, %{state | last_update_date: last_update_date}}

      {:error, error} ->
        {:stop, error, state}

      _ ->
        {:stop, :unexpected_result, state}
    end
  end

  def handle_cast({:send, msg}, state) do
    case @telegram.send(msg) do
      :ok -> {:noreply, state}
      {:error, err} -> {:stop, err, state}
    end
  end

  def send(msg), do: GenServer.cast(__MODULE__, {:send, msg})

  defp schedule_poll(), do: Process.send_after(self(), :poll, @polling_interval)
end
