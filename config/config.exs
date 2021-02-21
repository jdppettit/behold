# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :behold,
  ecto_repos: [Behold.Repo],
  email_module: Observer.Notification.Email

# Configures the endpoint
config :behold, BeholdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+PnWILkhAJ4Q6XhB+bEB0IvCowZ32tM0ATkAW+ePNmxYT5ZR7L+hrD0NQfe3BgtD",
  render_errors: [view: BeholdWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Behold.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :logger, backends: [:console, Gelfx]

config :logger, Gelfx,
  host: "graylog.pettit.home",
  hostname: "behold-api",
  protocol: :tcp,
  level: :debug

import_config "#{Mix.env}.exs"
