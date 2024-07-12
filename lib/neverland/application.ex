defmodule Neverland.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NeverlandWeb.Telemetry,
      Neverland.Repo,
      {DNSCluster, query: Application.get_env(:neverland, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Neverland.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Neverland.Finch},
      # Start a worker by calling: Neverland.Worker.start_link(arg)
      # {Neverland.Worker, arg},
      # Start to serve requests, typically the last entry
      {Neverland.Ghost, %{}, name: :ghost_demo1},
      {Neverland.Ghost, %{}, name: :ghost_demo2},
      NeverlandWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Neverland.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NeverlandWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
