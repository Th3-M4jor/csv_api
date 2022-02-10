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
end
