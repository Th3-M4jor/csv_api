defmodule CsvApi.Schema.Order do
  use Ecto.Schema
  alias CsvApi.Schema.Country

  schema "order" do
    field :type, :string
    field :sales_channel, Ecto.Enum, values: [online: "Online", offline: "Offline"]
    field :order_priority, :string
    field :order_date, :date
    field :ship_date, :date
    field :units_sold, :integer
    field :unit_price, :decimal
    field :unit_cost, :decimal
    field :total_revenue, :decimal
    field :total_cost, :decimal
    belongs_to :country, Country
  end
end
