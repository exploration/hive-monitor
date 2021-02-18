use Mix.Config

config :logger, backends: [{LoggerFileBackend, :monitor_log}, :console]

config :logger, :monitor_log,
  path: "log/hive_monitor.log",
  level: :info
