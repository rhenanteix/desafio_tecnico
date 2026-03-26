import Config

config :w_core, WCore.Repo,
  database: "w_core_dev.db",
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :w_core, WCoreWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "y0ZaIdyDtP0p6qLXK4aY6EJEUQlm1gKAWAiavNn01e450F22bkUQK7EVvVSaT0dI",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:w_core, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:w_core, ~w(--watch)]}
  ]

config :w_core, dev_routes: true
config :swoosh, :api_client, false
