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
#   :name, :cmd, :args [list], :rate (in ms)
config :hive_monitor, crons: [
  %{name: "echo_hello", cmd: "/bin/echo", args: ["hello"], rate: :timer.minutes(30)}
]

# The default configuration of the HIVE monitor is to run as a "server" to
# handle realtime inputs between Explo's various web systems (Portico, Portal,
# etc.). If you're using the HIVE monitor in other environments, you'll want to
# configure your handlers here.
config :hive_monitor, known_triplets: %{
  {"explo", "notification", "portico"} => [HiveMonitor.NotificationHandler],
  {"facapp", "user", "update"} => [HiveMonitor.FacAppHandler],
  {"portico", "bus_route", "update"} => [HiveMonitor.PortalHandler],
  {"portico", "course", "update"} => [HiveMonitor.PortalHandler],
  {"portico", "user", "update"} => [HiveMonitor.PortalHandler],
  {"portal_production","ambassador","update"} => [HiveMonitor.FMHandler],
  {"portal_production","arrival","update"} => [HiveMonitor.FMHandler],
  {"portal_production","bus_form","update"} => [HiveMonitor.FMHandler],
  {"portal_production","campdoc","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","course","update"} => [HiveMonitor.FMHandler],
  {"portal_production","departure","update"} => [HiveMonitor.FMHandler],
  {"portal_production","housing","update"} => [HiveMonitor.FMHandler],
  {"portal_production","mini_course","update"} => [HiveMonitor.FMHandler],
  {"portal_production","parent_eval","update"} => [HiveMonitor.FMHandler],
  {"portal_production","photo_id","update"} => [HiveMonitor.FMHandler],
  {"portal_production","student_tech","update"} => [HiveMonitor.FMHandler],
  {"portal_production","POR.AUTHVIS","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.BATTLEGROUNDZ.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.BERKSHIRE.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.BIKETOUR.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.BIKETOUR.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.BOSTON.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.BROWNSTONE.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.FOODBANK.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.GLASSBLOWING.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.GOKARTS.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.KAYAK.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.PAINTBALL.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.PAINTBALL.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.PARKOUR.WHEA","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.RAFTING.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.REALITYGAMING.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.RIVERKAYAKING.YALE","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.ROCKCLIMBING.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.ROCKCLIMBING.WHEA","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.SKYDIVING.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.SKYDIVING.WHEA","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.TRAPEZE.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.TRAPEZE.WHEA","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.TREETOP.WELL","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.TREETOP.WHEA","complete"} => [HiveMonitor.FMHandler],
  {"portal_production","WV.ZIPLINE.YALE","complete"} => [HiveMonitor.FMHandler]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
