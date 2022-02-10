defmodule CsvApi.Schema.Region do
  use Ecto.Schema
  alias CsvApi.Schema.Country

  @type t :: %__MODULE__{
    id: non_neg_integer(),
    name: String.t(),
    countries: [Country.t()] | Ecto.Association.NotLoaded.t(),
    orders: [Order.t()] | Ecto.Association.NotLoaded.t(),
  }

  schema "region" do
    field :name, :string
    has_many :countries, Country
    has_many :orders, through: [:countries, :orders]
  end
end
