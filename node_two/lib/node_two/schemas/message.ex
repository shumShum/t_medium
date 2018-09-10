defmodule NodeTwo.Message do
  use NodeTwo.Schema

  @rabbit Application.get_env(:node_two, :rabbit_service)

  schema "messages" do
    field(:text, :string)
    field(:date, :integer)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text, :date])
    |> validate_required([:text, :date])
  end

  def create(text, date) do
    if date > last_date(),
      do: %__MODULE__{} |> changeset(%{text: text, date: date}) |> NodeTwo.Repo.insert(),
      else: {:ok, nil}
  end

  def create(text) do
    %__MODULE__{}
    |> changeset(%{text: text, date: last_date() + 1})
    |> NodeTwo.Repo.insert()
    |> case do
      {:ok, msg} -> @rabbit.send(msg.text)
      {:error, _} = err -> err
    end
  end

  defp last_date() do
    from(m in __MODULE__, order_by: [desc: :date], limit: 1, select: m.date)
    |> NodeTwo.Repo.one()
    |> case do
      nil -> 0
      date -> date
    end
  end
end