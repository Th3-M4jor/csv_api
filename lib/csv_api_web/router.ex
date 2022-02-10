defmodule CsvApiWeb.Router do
  use CsvApiWeb, :router

  pipeline :api do
    plug :accepts, ["json", "csv"]
  end

  scope "/api", CsvApiWeb do
    pipe_through :api

    put "/csv", BaseController, :put_csv

    get "/order/:id", BaseController, :get_order

    get "/orders", BaseController, :get_orders

  end
end
