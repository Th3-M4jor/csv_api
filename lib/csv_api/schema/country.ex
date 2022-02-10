defmodule CsvApi.Schema.Country do
  use Ecto.Schema
  alias CsvApi.Schema.{Order, Region}

  schema "country" do
    field :name, :string
    belongs_to :region, Region
    has_many :orders, Order
  end
end
