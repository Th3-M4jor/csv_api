defmodule CsvApi.Repo do
  use Ecto.Repo,
    otp_app: :csv_api,
    adapter: Ecto.Adapters.SQLite3
end
