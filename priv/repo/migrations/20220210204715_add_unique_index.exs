defmodule CsvApi.Repo.Migrations.AddUniqueIndex do
  use Ecto.Migration

  def change do
    create index("region", [:name], unique: true)
    create index("country", [:name, :region_id], unique: true)
  end
end
