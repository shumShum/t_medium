defmodule NodeTwoWeb.MessageController do
  use NodeTwoWeb, :controller
  import Ecto.Query

  alias NodeTwo.Message

  def index(conn, _params) do
    messages = from(m in Message, order_by: :date) |> NodeTwo.Repo.all()
    changeset = %Message{} |> Message.changeset()

    conn |> render(messages: messages, changeset: changeset)
  end

  def create(conn, %{"message" => %{"text" => text}}) do
    with :ok <- Message.create(text) do
      conn |> redirect(to: message_path(conn, :index))
    end
  end
end
