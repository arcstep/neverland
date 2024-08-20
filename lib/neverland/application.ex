defmodule Neverland.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # 加载 .env 文件中的环境变量
    Dotenv.load()

    # 确保 :certifi 依赖已正确加载
    :application.ensure_all_started(:certifi)

    # 动态设置配置值
    cacerts = :certifi.cacerts()

    # 配置 Neverland.Mailer
    Application.put_env(:neverland, Neverland.Mailer,
      adapter: Swoosh.Adapters.SMTP,
      cacerts: cacerts,
      relay: System.get_env("SMTP_RELAY"),
      username: System.get_env("SMTP_USERNAME"),
      password: System.get_env("SMTP_PASSWORD"),
      ssl: true,
      tls: :always,
      auth: :always,
      port: 465,
      dkim: [
        s: "iyrw2408",
        d: "illufly.com",
        private_key: {:pem_plain, File.read!("priv/keys/dkim_private.pem")}
      ],
      retries: 2,
      no_mx_lookups: false
    )

    # 配置 Swoosh
    Application.put_env(:swoosh, :api_client, Swoosh.ApiClient.Hackney)

    Application.put_env(:swoosh, Swoosh.Adapters.SMTP,
      relay: System.get_env("SMTP_RELAY"),
      username: System.get_env("SMTP_USERNAME"),
      password: System.get_env("SMTP_PASSWORD"),
      ssl: true,
      tls: :always,
      auth: :always,
      port: 465,
      cacerts: cacerts
    )

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
