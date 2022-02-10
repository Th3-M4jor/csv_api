defmodule CsvApi.Schema.Country do
  use Ecto.Schema
  alias CsvApi.Schema.{Order, Region}

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          name: String.t(),
          region: Region.t() | Ecto.Association.NotLoaded.t(),
          region_id: non_neg_integer(),
          orders: [Order.t()] | Ecto.Association.NotLoaded.t()
        }

  schema "country" do
    field :name, :string
    belongs_to :region, Region
    has_many :orders, Order
  end
end
