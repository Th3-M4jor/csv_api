defmodule CsvApiWeb.BaseController do
  @moduledoc """
  Using a Single Controller for all the API calls for the sake of simplicity here.

  In a proper application, you would probably want to have a separate controller for each endpoint.
  """

  use CsvApiWeb, :controller
  require Logger

  @doc """
  Function for replacing all data in the database with the data from the CSV file.

  Phoenix stores uploaded files in a temporary directory, and deletes them when the request is completed.
  Supports the optional query parameter `?header=false` to indicate that the first line of the CSV file is not a header.

  This could be made more efficient by using a file Stream, chunking etc, however that would be more complex code.
  """
  def put_csv(conn, %{"file" => %Plug.Upload{path: path}} = params) do
    data = File.read!(path)

    lines =
      if params["header"] == "false" do
        # The `\R` regexp greedily matches all linebreak formats.
        String.split(data, ~r/\R/, trim: true)
      else
        # has a header, remove it
        [_header | lines] = String.split(data, ~r/\R/, trim: true)
        lines
      end

    ct = CsvApi.Schema.replace_csv(lines)

    resp(conn, 200, "#{ct} lines inserted")
  rescue
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      resp(conn, 500, "Internal Server Error")
  end

  def put_csv(conn, _params) do
    resp(conn, 400, "Missing file")
  end

  def add_csv(conn, %{"file" => %Plug.Upload{path: path}} = params) do
    data = File.read!(path)

    lines =
      if params["header"] == "false" do
        # The `\R` regexp greedily matches all linebreak formats.
        String.split(data, ~r/\R/, trim: true)
      else
        # has a header, remove it
        [_header | lines] = String.split(data, ~r/\R/, trim: true)
        lines
      end

    ct = CsvApi.Schema.add_csv(lines)
    resp(conn, 200, "#{ct} lines inserted")
  rescue
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      resp(conn, 500, "Internal Server Error")
  end

  @doc """
  Get a single order by ID.
  """
  def get_order(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case CsvApi.Schema.get_order_by_id(id) do
      {:ok, order} ->
        render(conn, "order.json", %{data: order})

      {:error, reason} ->
        resp(conn, 404, reason)
    end
  end

  @doc """
  Get all orders.
  """
  def get_orders(conn, _params) do
    data = CsvApi.Schema.get_all_orders()
    render(conn, "orders.json", %{data: data})
  end

  @doc """
  Delete an entire region.
  """
  def delete_region(conn, %{"name" => name}) do
    CsvApi.Schema.delete_region_by_name(name)
    resp(conn, 204, "")
  end

  def delete_region(conn, _params) do
    resp(conn, 400, "Missing region name")
  end

  @doc """
  Delete all orders from a region, leaving the region and countries in place.
  """
  def delete_region_orders(conn, %{"name" => name}) do
    CsvApi.Schema.delete_all_region_orders(name)
    resp(conn, 204, "")
  end

  @doc """
  Update all order sales channels.
  """
  def update_region_channel(conn, %{"name" => name, "channel" => channel})
      when is_binary(name) and is_binary(channel) do
    channel = String.capitalize(channel, :ascii)

    if channel not in ["Online", "Offline"] do
      resp(conn, 400, "Invalid channel type, expects \"Online\" or \"Offline\"")
    else
      CsvApi.Schema.update_region_sales_channel(name, channel)
      resp(conn, 204, "")
    end
  end

  def update_region_channel(conn, _params) do
    resp(conn, 400, "Missing region name or channel type")
  end
end
