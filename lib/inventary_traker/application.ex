defmodule InventaryTraker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InventaryTrakerWeb.Telemetry,
      InventaryTraker.Repo,
      {DNSCluster, query: Application.get_env(:inventary_traker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: InventaryTraker.PubSub},
      # Start a worker by calling: InventaryTraker.Worker.start_link(arg)
      # {InventaryTraker.Worker, arg},
      # Start to serve requests, typically the last entry
      InventaryTrakerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InventaryTraker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InventaryTrakerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
