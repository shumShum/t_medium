defmodule NodeOne.DispatcherTest do
  use ExUnit.Case

  alias NodeOne.Dispatcher

  @telegram Application.get_env(:node_one, :telegram_service)
  @rabbit Application.get_env(:node_one, :rabbit_service)

  describe "N2 to T" do
    test "receive msg from N2 and send it to T" do
      msg = "test msg"

      @telegram.setup_tester(self())
      @rabbit.receive(msg)

      receive do
         :sended -> :ok
      after
        1000 -> flunk("Message isn't sended.")
      end

      assert @telegram.sended() == [msg]
    end
  end

  describe "T to N2" do
    test "receive msg from T and send it to N2" do
      msg = "test msg"

      @rabbit.setup_tester(self())
      @telegram.receive(msg)

      Process.send(Dispatcher, :poll, [])

      receive do
         :sended -> :ok
      after
        1000 -> flunk("Message isn't sended.")
      end

      [sended] = @rabbit.queue_to()
      assert sended |> Poison.decode!() |> Map.get("text") == msg
    end
  end
end