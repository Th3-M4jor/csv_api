defmodule CsvApiWeb.BaseControllerTest do
  use CsvApiWeb.ConnCase, async: false

  test "PUT /api/csv/", %{conn: _conn} do
    conn = put(build_conn(), "/api/csv/", %{"file" => %Plug.Upload{path: "./test/test.csv", content_type: "text/csv", filename: "test.csv"}})
    assert conn.resp_body =~ "100 lines inserted"
  end

  test "POST /api/csv/", %{conn: _conn} do
    conn = put(build_conn(), "/api/csv/", %{"file" => %Plug.Upload{path: "./test/test.csv", content_type: "text/csv", filename: "test.csv"}})
    assert conn.resp_body =~ "100 lines inserted"
  end

  test "GET /api/orders/", %{conn: _conn} do

    # need to ensure DB is populated since all tests are sandboxed from each other
    conn = put(build_conn(), "/api/csv/", %{"file" => %Plug.Upload{path: "./test/test.csv", content_type: "text/csv", filename: "test.csv"}})
    assert conn.resp_body =~ "100 lines inserted"

    # Actual test starts here
    conn = get(build_conn(), "/api/orders/")
    body = json_response(conn, 200)
    assert is_list(body)
    assert length(body) > 0

    [first | _rest] = body
    assert is_map(first)
    id = first["order_id"]
    assert is_integer(id)

    conn = get(build_conn(), "/api/order/#{id}")
    body = json_response(conn, 200)
    assert is_map(body)
  end

  test "DELETE /api/region/data", %{conn: _conn} do
    conn = delete(build_conn(), "/api/region/data", %{"name" => "Asia"})
    assert conn.status == 204
  end

  test "PATCH /api/region/channel", %{conn: _conn} do
    conn = patch(build_conn(), "/api/region/channel", %{"name" => "North America", "channel" => "Offline"})
    assert conn.status == 204
  end

  # test error handling
  test "Error GET /api/order/:id", %{conn: _conn} do
    order_id = "NOT_AN_INTEGER" # An obviously invalid order id
    conn = get(build_conn(), "/api/order/#{order_id}")
    assert conn.status == 400
  end

  test "Error PUT /api/csv/", %{conn: _conn} do
    conn = put(build_conn(), "/api/csv/", %{})
    assert conn.status == 400
  end

  test "Error POST /api/csv/", %{conn: _conn} do
    conn = post(build_conn(), "/api/csv/", %{})
    assert conn.status == 400
  end

  test "Error DELETE /api/region/data", %{conn: _conn} do
    conn = delete(build_conn(), "/api/region/data", %{})
    assert conn.status == 400
  end

  test "Error PATCH /api/region/channel", %{conn: _conn} do
    conn = patch(build_conn(), "/api/region/channel", %{})
    assert conn.status == 400
  end

end
