import Config

# Config geral
config :w_core,
  ecto_repos: [WCore.Repo],
  generators: [timestamp_type: :utc_datetime]

# Adapter (GLOBAL - correto)
config :w_core, WCore.Repo,
  adapter: Ecto.Adapters.SQLite3

# Endpoint
config :w_core, WCoreWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WCoreWeb.ErrorHTML, json: WCoreWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WCore.PubSub,
  live_view: [signing_salt: "U/WvfV5o"]

# Mailer
config :w_core, WCore.Mailer,
  adapter: Swoosh.Adapters.Local

# Esbuild
config :esbuild,
  version: "0.25.4",
  w_core: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Tailwind
config :tailwind,
  version: "4.1.12",
  w_core: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# JSON
config :phoenix, :json_library, Jason

# IMPORTANTE: isso tem que ficar no FINAL
import_config "#{config_env()}.exs"
