defmodule CsvApiWeb.BaseView do
  use CsvApiWeb, :view

  def render("index.json", %{data: data}) do
    data
  end
end
