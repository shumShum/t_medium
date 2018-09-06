defmodule NodeOne.Dispatcher do
  use GenServer
  require Logger

  alias NodeOne.TelegramService

  @polling_interval Application.get_env(:node_one, __MODULE__)[:polling_interval]

  def init(_) do
    # case TelegramService.check() do
    #   :ok ->
    #     Logger.info("Dispatcher started")
    #     schedule_poll()
    #     {:ok, %{last_update_date: 0}}

    #   {:error, error} ->
    #     Logger.error("Telegram not available: #{inspect(error)}")
    #     {:stop, error}
    # end

    {:ok, %{last_update_date: 0}}
  end

  def handle_info(:poll, state) do
    case TelegramService.updates(state.last_update_date) do
      {:ok, messages, last_update_date} ->
        for msg <- messages do
          Logger.info("Message: #{msg}")
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
    case NodeOne.TelegramService.send(msg) do
      :ok -> {:noreply, state}
      {:error, err} -> {:stop, err, state}
    end
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def send(msg), do: GenServer.cast(__MODULE__, {:send, msg})

  defp schedule_poll(),
    do: Process.send_after(self(), :poll, @polling_interval)
end
