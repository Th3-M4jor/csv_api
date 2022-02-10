defmodule CsvApi.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table("region") do
      add :name, :text, null: false
    end

    create table("country") do
      add :name, :string, null: false
      add :region_id, references("region", on_update: :update_all, on_delete: :delete_all)
    end

    create table("order") do
      add :type, :string, null: false
      add :sales_channel, :string, null: false
      add :order_priority, :string, null: false
      add :order_date, :date, null: false
      add :ship_date, :date, null: false
      add :units_sold, :integer, null: false
      add :unit_price, :decimal, null: false
      add :unit_cost, :decimal, null: false
      add :total_revenue, :decimal, null: false
      add :total_cost, :decimal, null: false
      add :total_profit, :decimal, null: false
      add :country_id, references("country", on_update: :update_all, on_delete: :delete_all)
    end
  end
end
