defmodule CsvApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CsvApi.Repo,
      # Start the Telemetry supervisor
      CsvApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CsvApi.PubSub},
      # Start the Endpoint (http/https)
      CsvApiWeb.Endpoint
      # Start a worker by calling: CsvApi.Worker.start_link(arg)
      # {CsvApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CsvApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CsvApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
