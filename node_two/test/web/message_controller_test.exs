defmodule NodeTwoWeb.MessageControllerTest do
  use NodeTwoWeb.ConnCase

  alias NodeTwo.{Repo, Message}

  @rabbit Application.get_env(:node_two, :rabbit_service)

  test "#index: GET /", %{conn: conn} do
    existed_msg = "Index test message text"
    %Message{text: existed_msg, date: 1} |> Repo.insert!()

    @rabbit.setup_tester(self())

    received_msg = "Received message text"
    @rabbit.receive(%{text: received_msg, date: 15})

    receive do
       :received -> :ok
    after
      1000 -> flunk("Message isn't received.")
    end

    old_msg = "Old message text"
    @rabbit.receive(%{text: received_msg, date: 10})

    receive do
       :received -> :ok
    after
      1000 -> flunk("Message isn't sended.")
    end

    response =
      conn |> get("/") |> html_response(200)

    assert response =~ existed_msg
    assert response =~ received_msg
    refute response =~ old_msg
  end

  test "#create POST /messages", %{conn: conn} do
    msg = "Create test message text"
    @rabbit.setup_tester(self())

    conn |> post("/messages", message: %{text: msg}) |> html_response(302)

    receive do
       :sended -> :ok
    after
      1000 -> flunk("Message isn't sended.")
    end

    assert Repo.get_by(Message, text: msg)
    assert @rabbit.queue_to() == [msg]
  end
end
