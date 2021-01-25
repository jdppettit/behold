defmodule Behold.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
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
