defmodule CsvApiWeb.BaseView do
  use CsvApiWeb, :view

  def render("index.json", %{data: data}) do
    data
  end

  def render("order.json", %{data: order}) do
    order_to_map(order)
  end

  def render("orders.json", %{data: orders}) do
    Enum.map(orders, &order_to_map/1)
  end

  defp order_to_map(order) do
    sales_channel = Atom.to_string(order.sales_channel) |> String.capitalize(:ascii)

    %{
      order_id: order.id,
      type: order.type,
      sales_channel: sales_channel,
      order_priority: order.order_priority,
      order_date: order.order_date,
      ship_date: order.ship_date,
      units_sold: order.units_sold,
      unit_price: order.unit_price,
      unit_cost: order.unit_cost,
      total_revenue: order.total_revenue,
      total_cost: order.total_cost,
      total_profit: order.total_profit,
      country: order.country_name,
      region: order.region_name
    }
  end
end
