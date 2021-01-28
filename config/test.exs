use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :behold, BeholdWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :behold, Behold.Repo,
  database: "behold_test",
  username: "behold",
  password: "beholdtest",
  pool: Ecto.Adapters.SQL.Sandbox

config :observer, Observer.Common.Mailer,
  adapter: Bamboo.LocalAdapter

config :behold,
  email_module: EmailNotificationMock
