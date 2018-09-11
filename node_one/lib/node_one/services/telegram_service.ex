defmodule NodeOne.TelegramService do
  require Logger

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
        channel_id = config(:channel_id) |> String.to_integer()

        messages =
          for %{
                "channel_post" => %{
                  "chat" => %{"id" => ^channel_id},
                  "date" => date,
                  "text" => text
                }
              } <- updates,
              date > last_date,
              do: %{text: text, date: date}

        {:ok, messages}

      {:error, _} = err ->
        err

      _ ->
        {:error, :unexpected_result}
    end
  end

  def send(message) do
    case request(:post, "sendMessage", chat_id: config(:channel_id), text: message) do
      {:ok, %{"ok" => true}} -> :ok
      {:error, _} = err -> err
      _ -> {:error, :unexpected_result}
    end
  end

  defp request(http_method, telegram_method, params \\ []) do
    url = [config(:url), "bot" <> config(:token), telegram_method] |> Path.join()
    body = params |> Map.new() |> Poison.encode!()
    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.request(http_method, url, body, headers) do
      {:ok, %{status_code: sc, body: body}} when sc in 200..299 -> {:ok, Poison.decode!(body)}
      {:ok, %{body: body}} -> {:error, Poison.decode!(body)}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end

  defp config(key) do
    case Application.get_env(:node_one, __MODULE__)[key] do
      {:system, env_var_name} -> System.get_env(env_var_name)
      value -> value
    end
  end
end
