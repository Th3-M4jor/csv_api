defmodule CsvApi.Schema do
  @moduledoc """
  This module provides a simple interface to the inner table schema
  """

  require Logger
  import Ecto.Query
  alias CsvApi.Repo
  alias CsvApi.Schema.{Country, Order, Region}

  def get_all do
    query = from c in Country, preload: [:orders, :region]
    Repo.all(query)
  end

  @spec replace_csv(Enum.t()) :: non_neg_integer()
  def replace_csv(lines) do

    # Erase any existing data.
    # Deleting all regions will also delete all orders and countries.
    Repo.delete_all(Region)

    row_maps = lines |> Stream.map(fn line ->
      String.split(line, ",")
    end) |> Stream.map(&row_to_map/1)

    region_map = row_to_region_map(row_maps)

    country_map = row_to_country_map(region_map, row_maps)

    order_list = insert_orders(country_map, row_maps)

    length(order_list)

  end

  defp row_to_region_map(row_maps) do
    row_maps |> Stream.map(fn row_map ->
      row_map.region
    end) |> Enum.sort() |> Enum.dedup() |> Enum.map(fn region ->
      region = %Region{name: region} |> Repo.insert!()
      {region.name, region}
    end) |> Map.new()
  end

  defp row_to_country_map(region_map, row_maps) do
    row_maps |> Stream.map(fn row_map ->
      {row_map.country, row_map.region}
    end) |> Enum.sort() |> Enum.dedup() |> Enum.map(fn {country, region} ->
      region_id = region_map[region].id
      country = %Country{name: country, region_id: region_id} |> Repo.insert!()
      {{region, country.name}, country}
    end) |> Map.new()
  end

  defp insert_orders(country_map, row_maps) do
    row_maps |> Stream.map(fn row_map ->
      country_id = country_map[{row_map.region, row_map.country}].id
      %Order{
        id: row_map.order_id,
        type: row_map.item_type,
        country_id: country_id,
        sales_channel: row_map.sales_channel,
        order_date: row_map.order_date,
        order_priority: row_map.order_priority,
        ship_date: row_map.ship_date,
        units_sold: row_map.units_sold,
        unit_price: row_map.unit_price,
        unit_cost: row_map.unit_cost,
        total_revenue: row_map.total_revenue,
        total_cost: row_map.total_cost,
      } |> Repo.insert!()
    end) |> Enum.to_list()
  end

  @spec row_to_map([String.t()]) :: map()
  defp row_to_map(row) do
    Logger.debug("Parsing row: #{Kernel.inspect(row)}")
    # A proper row should have 14 columns. Will raise a match error if not
    [region, country, item_type, sales_channel, order_priority, order_date, order_id, ship_date, units_sold, unit_price, unit_cost, total_revenue, total_cost, total_profit] = row

    # Convert the date strings to Date objects
    order_date = parse_date_str(order_date)
    ship_date = parse_date_str(ship_date)

    # Convert the numeric strings to numbers
    units_sold = String.to_integer(units_sold)
    order_id = String.to_integer(order_id)
    unit_price = Decimal.new(unit_price)
    unit_cost = Decimal.new(unit_cost)
    total_revenue = Decimal.new(total_revenue)
    total_cost = Decimal.new(total_cost)
    total_profit = Decimal.new(total_profit)

    # Convert the sales channel to an existing atom
    sales_channel = sales_channel |> String.downcase(:ascii) |> String.to_existing_atom()

    %{
      region: region,
      country: country,
      item_type: item_type,
      sales_channel: sales_channel,
      order_priority: order_priority,
      order_date: order_date,
      order_id: order_id,
      ship_date: ship_date,
      units_sold: units_sold,
      unit_price: unit_price,
      unit_cost: unit_cost,
      total_revenue: total_revenue,
      total_cost: total_cost,
      total_profit: total_profit
    }
  end

  @spec parse_date_str(String.t()) :: Date.t()
  defp parse_date_str(str) do
    Logger.debug("Parsing date string: #{str}")
    [month, day, year] = String.split(str, "/")
    day = String.to_integer(day)
    month = String.to_integer(month)
    year = String.to_integer(year)
    Date.new!(year, month, day)
  end

end
