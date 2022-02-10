defmodule CsvApiWeb.BaseView do
  use CsvApiWeb, :view

  def render("index.json", %{data: data}) do
    data
  end

  def render("orders.json", %{data: orders}) do
    for order <- orders do
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
        country: order.country_name,
        region: order.region_name
      }
    end
  end
end
