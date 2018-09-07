defmodule NodeTwo.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :text
      add :date, :integer
    end

    create index(:messages, :date)
  end
end