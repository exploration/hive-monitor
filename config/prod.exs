use Mix.Config

# Do not print debug messages in production
config :logger,
  level: :info,
  backends: [{LoggerFileBackend, :monitor_log}, :console]

config :logger, :monitor_log,
  path: "log/hive_monitor.log",
  level: :info
