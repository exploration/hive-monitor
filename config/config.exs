# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# If you have any "Cron" (periodically-run) tasks that you need HiveMonitor to
# manage, you can set them up here.
# For a CRON to work, you need:
#
#   :name, :module, :fun, args [list], :rate (in ms)
config :hive_monitor, crons: [
  %{
    name: "handle_missed_atoms",
    module: HiveMonitor.Handler,
    fun: :handle_missed_atoms,
    args: [],
    rate: :timer.hours(4)
  },
  %{
    name: "echo_hello",
    module: System,
    fun: :cmd,
    args: ["/bin/echo",["hello"]],
    rate: :timer.minutes(60)
  }
]

# The default configuration of the HIVE monitor is to run as a "server" to
# handle realtime inputs between Explo's various web systems (Portico, Portal,
# etc.). If you're using the HIVE monitor in other environments, you'll want to
# configure your handlers here.
config :hive_monitor, router_config: %{
  {"explo", "notification", "create"} => [HiveMonitor.NotificationHandler]
}

# Default people to notify in chat
config :hive_monitor, default_chat_recipients: ["Donald"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
