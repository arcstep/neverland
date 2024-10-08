defmodule Neverland.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NeverlandWeb.Telemetry,
      Neverland.Repo,
      {DNSCluster, query: Application.get_env(:neverland, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Neverland.PubSub},
      {Finch, name: Neverland.Finch},
      {Neverland.Sandbox.Python, name: :sandbox_python},
      Supervisor.child_spec({Neverland.Ghost, name: :ghost_demo1}, id: :ghost_demo1),
      Supervisor.child_spec({Neverland.Ghost, name: :ghost_demo2}, id: :ghost_demo2),
      {Neverland.OnlineUsers, name: :online_users},
      NeverlandWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Neverland.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NeverlandWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
