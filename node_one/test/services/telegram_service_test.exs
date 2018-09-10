defmodule NodeOne.TelegramServiceTest do
  use ExUnit.Case
  import Mock

  alias NodeOne.TelegramService

  @config Application.get_env(:node_one, NodeOne.TelegramService)
  @url @config[:url]
  @token @config[:token]
  @channel_id @config[:channel_id]

  def url(method), do: [@url, "bot" <> @token, method] |> Path.join()

  describe "#check/0" do
    test "ok" do
      url = url("getMe")

      with_mock HTTPoison,
        request: fn :get, ^url, _, _ -> {:ok, %{status_code: 200, body: "{\"ok\": true}"}} end do
        assert TelegramService.check() == :ok
      end
    end

    test "error" do
      url = url("getMe")

      with_mock HTTPoison,
        request: fn :get, ^url, _, _ -> {:error, %{reason: "error"}} end do
        assert TelegramService.check() == {:error, "error"}
      end
    end
  end

  describe "#updates/1" do
    test "return filtered messages" do
      url = url("getUpdates")

      updates = [
        %{channel_post: %{chat: %{id: @channel_id}, date: 5, text: "5"}},
        %{channel_post: %{chat: %{id: @channel_id}, date: 11, text: "11"}},
        %{chat_messaget: %{date: 15, text: "15"}},
        %{channel_post: %{chat: %{id: @channel_id}, date: 22, text: "22"}},
        %{channel_post: %{chat: %{id: 66}, date: 25, text: "25"}}
      ]

      body = %{ok: true, result: updates} |> Poison.encode!()

      with_mock HTTPoison,
        request: fn :get, ^url, _, _ -> {:ok, %{status_code: 200, body: body}} end do
        messages = [
          %{text: "11", date: 11},
          %{text: "22", date: 22}
        ]

        assert TelegramService.updates(10) == {:ok, messages}
      end
    end
  end

  describe "#send/1" do
    test "ok" do
      url = url("sendMessage")

      with_mock HTTPoison,
        request: fn :post, ^url, _, _ -> {:ok, %{status_code: 200, body: "{\"ok\": true}"}} end do
        assert TelegramService.send("test") == :ok
      end
    end
  end
end
