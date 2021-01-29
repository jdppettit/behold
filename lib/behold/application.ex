defmodule Behold.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    topologies = [
      kubernetes: [
        strategy: Elixir.Cluster.Strategy.Kubernetes,
        config: [
          mode: :ip,
          kubernetes_node_basename: "behold",
          kubernetes_selector: "app=behold-api",
          kubernetes_namespace: "behold",
          polling_interval: 10_000
        ]
      ]
    ]

    # Define workers and child supervisors to be supervised
    children = [
      #{Cluster.Supervisor, [topologies, [name: Behold.ClusterSupervisor]]},
      # Start the Ecto repository
      supervisor(Behold.Repo, []),
      # Start the endpoint when the application starts
      supervisor(BeholdWeb.Endpoint, []),
      # Start scheduling supervisor
      %{
        id: Observer.Supervisor.SchedulerSupervisor,
        start: {Observer.Supervisor.SchedulerSupervisor, :start_link, [[]]}
      },
      # Start notification supervisor
      %{
        id: Observer.Supervisor.NotificationSupervisor,
        start: {Observer.Supervisor.NotificationSupervisor, :start_link, [[]]}
      }
    ]

    Behold.Common.MetricsSetup.setup()

    opts = [strategy: :one_for_one, name: Behold.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    BeholdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
