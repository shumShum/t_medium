defmodule NodeOne.TelegramService do
  require Logger

  @config Application.get_env(:node_one, __MODULE__)
  @url @config[:url]
  @token @config[:token]
  @channel_id @config[:channel_id]

  def check() do
    case request(:get, "getMe") do
      {:ok, %{"ok" => true}} -> :ok
      {:error, _} = err -> err
      _ -> {:error, :unexpected_result}
    end
  end

  def updates(last_date \\ 0) do
    case request(:get, "getUpdates") do
      {:ok, %{"ok" => true, "result" => updates}} ->
        selected_updates =
          for %{
                "channel_post" => %{
                  "chat" => %{"id" => @channel_id},
                  "date" => date,
                  "text" => _
                }
              } = post <- updates,
              date > last_date,
              do: post

        new_last_date = selected_updates |> List.last() |> get_in(["channel_post", "date"])
        messages = selected_updates |> Enum.map(&(&1 |> get_in(["channel_post", "text"])))
        {:ok, messages, new_last_date || last_date}

      {:error, _} = err ->
        err

      _ ->
        {:error, :unexpected_result}
    end
  end

  def send(message) do
    case request(:post, "sendMessage", chat_id: @channel_id, text: message) do
      {:ok, %{"ok" => true}} -> :ok
      {:error, _} = err -> err
      _ -> {:error, :unexpected_result}
    end
  end

  defp request(http_method, telegram_method, params \\ []) do
    url = [@url, "bot" <> @token, telegram_method] |> Path.join()
    body = params |> Map.new() |> Poison.encode!()
    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.request(http_method, url, body, headers) do
      {:ok, %{status_code: sc, body: body}} when sc in 200..299 -> {:ok, Poison.decode!(body)}
      {:ok, %{body: body}} -> {:error, Poison.decode!(body)}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end
end