defmodule CsvApiWeb.Router do
  use CsvApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CsvApiWeb do
    pipe_through :api

    get "/", BaseController, :index

  end
end
