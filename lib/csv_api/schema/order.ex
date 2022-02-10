defmodule CsvApi.Schema.Order do
  @moduledoc """
  This module defines the Order schema.
  """

  use Ecto.Schema
  alias CsvApi.Schema.Country

  @typedoc """
  `:country_name` and `:region_name` are virtual fields, which means they are not stored in the database.
  To get the country name and region name, you need to query the country and region table.
  By doing a join, for an example, see `CsvApi.Schema.get_order_by_id/1`.
  """
  @type t :: %__MODULE__{
          id: non_neg_integer(),
          country_id: non_neg_integer(),
          country_name: String.t() | nil,
          region_name: String.t() | nil,
          country: Country.t() | Ecto.Association.NotLoaded.t(),
          type: String.t(),
          sales_channel: :online | :offline,
          order_priority: String.t(),
          order_date: Date.t(),
          ship_date: Date.t(),
          units_sold: non_neg_integer(),
          unit_price: Decimal.t(),
          unit_cost: Decimal.t(),
          total_revenue: Decimal.t(),
          total_cost: Decimal.t()
        }

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
    field :total_profit, :decimal
    field :country_name, :string, virtual: true
    field :region_name, :string, virtual: true
    belongs_to :country, Country
  end
end
