import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :battleships_web, BattleshipsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "n7GWrmu4dBJdLo09cpkUrao4MfFYEQMJLDAl3yId84fhmDwIxw8QgRMuLGEM0MtE",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
