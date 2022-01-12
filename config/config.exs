# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :battleships,
  battle_repository: Battleships.Game.BattleRepository,
  board_repository: Battleships.Game.BoardRepository

config :battleships_web,
  generators: [context_app: :battleships]

# Configures the endpoint
config :battleships_web, BattleshipsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BattleshipsWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Battleships.PubSub,
  live_view: [signing_salt: "OL/onwIt"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/battleships_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
