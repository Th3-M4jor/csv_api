defmodule CsvApiWeb.BaseController do
  use CsvApiWeb, :controller
  require Logger

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, req) do
    render(conn, "index.json", %{data: req})
  end


  def put_csv(conn, %{"file" => %Plug.Upload{} = file} = params) do
    data = File.read!(file.path)

    lines = if params["header"] == "false" do
      String.split(data, ~r/\R/, trim: true)
    else
      #has a header, remove it
      [_header | lines] = String.split(data, ~r/\R/, trim: true)
      lines
    end

    ct = CsvApi.Schema.replace_csv(lines)

    resp(conn, 200, "#{ct} lines inserted")

  rescue
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      resp(conn, 500, "Error")
  end

  def get_json(conn, _params) do
    data = CsvApi.Schema.get_all()
    render(conn, "orders.json", %{data: data})
  end

end
