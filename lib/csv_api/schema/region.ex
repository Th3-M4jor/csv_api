defmodule CsvApi.Schema.Region do
  use Ecto.Schema
  alias CsvApi.Schema.Country

  schema "region" do
    field :name, :string
    has_many :countries, Country
    has_many :orders, through: [:countries, :orders]
  end
end
