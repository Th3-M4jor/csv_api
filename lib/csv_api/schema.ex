defmodule CsvApi.Schema do
  @moduledoc """
  This module provides a simple interface to the inner Database schema.
  """

  require Logger
  import Ecto.Query
  alias CsvApi.Repo
  alias CsvApi.Schema.{Country, Order, Region}

  @doc """
  This function returns a list of all countries in the database

  When preload is true, the associated region and orders are also loaded
  """
  @spec get_all_countries(boolean()) :: [Country.t()]
  def get_all_countries(preload \\ false) do
    query =
      if preload do
        from c in Country, preload: [:orders, :region]
      else
        Country
      end

    Repo.all(query)
  end

  @doc """
  Returns all orders, sorted by region then country then order id
  """
  @spec get_all_orders() :: [Order.t()]
  def get_all_orders do
    query =
      from o in Order,
        join: c in Country,
        on: o.country_id == c.id,
        join: r in Region,
        on: c.region_id == r.id,
        select: {o, c.name, r.name},
        order_by: [r.name, c.name, o.id]

    Repo.all(query)
    |> Enum.map(fn {order, country_name, region_name} ->
      # update the order's virtual fields with the country and region names
      %{order | country_name: country_name, region_name: region_name}
    end)
  end

  @doc """
  Fetch a single order by id, populates it's country_name and region_name fields.
  """
  @spec get_order_by_id(non_neg_integer()) ::
          {:error, String.t()} | {:ok, Order.t()}
  def get_order_by_id(id) when is_integer(id) do
    query =
      from o in Order,
        join: c in Country,
        on: o.country_id == c.id,
        join: r in Region,
        on: c.region_id == r.id,
        where: o.id == ^id,
        select: {o, c.name, r.name}

    case Repo.one(query) do
      nil ->
        {:error, "Order not found"}

      {order, country_name, region_name} ->
        # update the order's virtual fields with the country and region names
        {:ok, %{order | country_name: country_name, region_name: region_name}}
    end
  end

  @spec get_region_by_name(String.t()) :: Region.t() | nil
  def get_region_by_name(name) when is_binary(name) do
    query =
      from r in Region,
        where: r.name == ^name,
        select: r

    Repo.one(query)
  end

  @doc """
  Deletes a region as well as all associated countries and orders
  """
  @spec delete_region_by_name(String.t()) :: :ok
  def delete_region_by_name(name) when is_binary(name) do
    query =
      from r in Region,
        where: r.name == ^name

    Repo.delete_all(query)
    :ok
  end

  @doc """
  Deletes all orders for a given region, keeping the region and countries
  """
  @spec delete_all_region_orders(region_name :: String.t()) :: :ok
  def delete_all_region_orders(region_name) when is_binary(region_name) do
    query =
      from o in Order,
        join: c in Country,
        on: o.country_id == c.id,
        join: r in Region,
        on: c.region_id == r.id,
        where: r.name == ^region_name

    Repo.delete_all(query)
    :ok
  end

  @doc """
  Sets all orders within a given region to the given sales channel type

  Throws an error if the sales channel type is not `"Online"` or `"Offline"`
  """
  @spec update_region_sales_channel(region_name :: String.t(), sales_channel :: String.t()) :: :ok
  def update_region_sales_channel(region_name, sales_channel)
      when is_binary(region_name) and sales_channel in ["Online", "Offline"] do
    query =
      from o in Order,
        join: c in Country,
        on: o.country_id == c.id,
        join: r in Region,
        on: c.region_id == r.id,
        where: r.name == ^region_name,
        update: [set: [sales_channel: ^sales_channel]]

    Repo.update_all(query, [])
    :ok
  end

  @doc """
  Clears the database and re-inserts everything

  Duplicate order ids replace the existing order
  """
  @spec replace_csv(Enum.t()) :: non_neg_integer()
  def replace_csv(lines) do
    # Erase any existing data.
    # Deleting all regions will also delete all orders and countries.
    Repo.delete_all(Region)

    add_csv(lines)
  end

  @doc """
  Inserts a CSV file into the database without erasing

  Duplicate order ids replace the existing order

  Uses `Flow` to improve parallelism, gave almost a 2x speedup on my machine
  """
  @spec add_csv(Enum.t()) :: non_neg_integer()
  def add_csv(lines) do

    # For performance, compile the split pattern once, instead of every time String.split is called
    comma_pattern = :binary.compile_pattern(",")

    lines
    |> Flow.from_enumerable(max_demand: 100)
    |> Flow.partition()
    |> Flow.map(&String.split(&1, comma_pattern))
    |> Flow.map(&row_to_map/1)
    |> Flow.map(&row_map_to_order/1)
    # Call Enum.count to force Flow to run, then return the count
    |> Enum.count()
  end

  defp row_map_to_order(row_map) do
    country_name = row_map.country
    region_name = row_map.region

    region = get_or_insert_region(region_name)
    country = get_or_insert_country(region, country_name)

    %Order{
      id: row_map.order_id,
      type: row_map.item_type,
      country_id: country.id,
      sales_channel: row_map.sales_channel,
      order_date: row_map.order_date,
      order_priority: row_map.order_priority,
      ship_date: row_map.ship_date,
      units_sold: row_map.units_sold,
      unit_price: row_map.unit_price,
      unit_cost: row_map.unit_cost,
      total_revenue: row_map.total_revenue,
      total_cost: row_map.total_cost,
      total_profit: row_map.total_profit
    }
    |> Repo.insert!(on_conflict: :replace_all)
  end

  @spec get_or_insert_region(region_name :: String.t()) :: Region.t()
  defp get_or_insert_region(region_name) do
    # Attempt to insert the region, if it already exists, id will remain nil
    region = %Region{name: region_name} |> Repo.insert!(on_conflict: :nothing)

    # If the region already exists, then we need to fetch it
    if is_nil(region.id) do
      Repo.one!(from r in Region, where: r.name == ^region_name)
    else
      region
    end
  end

  @spec get_or_insert_country(region :: Region.t(), country_name :: String.t()) :: Country.t()
  defp get_or_insert_country(%Region{} = region, country_name) do
    # Attempt to insert the country, if a country in that region already exists, id will remain nil
    country =
      %Country{name: country_name, region_id: region.id} |> Repo.insert!(on_conflict: :nothing)

    # If the country already exists, must re-fetch due to DB limitations
    if is_nil(country.id) do
      Repo.one!(from c in Country, where: c.name == ^country_name and c.region_id == ^region.id)
    else
      country
    end
  end

  @spec row_to_map([String.t()]) :: map()
  defp row_to_map(row) do
    Logger.debug("Parsing row: #{Kernel.inspect(row)}")
    # A proper row should have 14 columns. Will raise a match error if not
    [
      region,
      country,
      item_type,
      sales_channel,
      order_priority,
      order_date,
      order_id,
      ship_date,
      units_sold,
      unit_price,
      unit_cost,
      total_revenue,
      total_cost,
      total_profit
    ] = row

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

    # Convert the sales channel to an atom
    sales_channel =
      case String.downcase(sales_channel, :ascii) do
        "online" -> :online
        "offline" -> :offline
      end

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
