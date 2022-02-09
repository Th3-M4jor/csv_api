defmodule CsvApiWeb.BaseController do
  use CsvApiWeb, :controller

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, req) do
    render(conn, "index.json", %{data: req})
  end

end
