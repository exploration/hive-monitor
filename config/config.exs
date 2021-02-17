# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# You'll probably want some tokens
config :hive_monitor,
  hive_socket_token: "xaDeqPCwnwMzGSRq3RIaEgmmQR85Kmqe5Fa6vQhEqGLkMe8HW6bO7hwUJLYqj6z",
  default_chat_url: "https://chat.googleapis.com/v1/spaces/AAAAE-QM4B4/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=AEZXKQ-qA80d05_VcFTaVd-tFq1eq-Be58Uev_Hs8UY%3D"

config :hive_service,
  hive_api_token: "G0iIkduflP4wMmSRO8x8KLzk1EZIYIYnIo7sl7y5GQYuQ44XCgYaMcfh7RJVHhr"

# If you have any "Cron" (periodically-run) tasks that you need HiveMonitor to
# manage, you can set them up here.
# For a CRON to work, you need:
#   :name, :cmd, :args [list], :rate (in ms)
config :hive_monitor, crons: [
  %{
    name: "handle_missed_atoms",
    module: HiveMonitor.Handler,
    fun: :handle_missed_atoms,
    args: [],
    rate: :timer.minutes(30)
  },
  #%{
    #name: "filemaker_quit",
    #module: System,
    #fun: :cmd,
    #args: ["/Users/exploadmin/Cron/filemaker_quit.sh", []],
    #rate: :timer.hours(2)
  #}
  #%{
    #name: "filemaker_activate",
    #module: System,
    #fun: :cmd,
    #args: ["/Users/exploadmin/Cron/filemaker_activate.sh", []],
    #rate: :timer.minutes(1)
  #}
]

# The default configuration of the HIVE monitor is to run as a "server" to
# handle realtime inputs between Explo's various web systems (Portico, Portal,
# etc.). If you're using the HIVE monitor in other environments, you'll want to
# configure your handlers here.
config :hive_monitor, router_config: %{
  #{"courses_production", "version", "approved"} => [HiveMonitor.PorticoBuffer],
  #{"courses_production", "version", "published"} => [HiveMonitor.PorticoBuffer],
  #{"courses_production", "version", "destroyed"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "profile", "update"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "participant", "update"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.GETTINGSTARTED", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.PROGRAMSELECTION", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.COURSESELECTION", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.FAMILYINFO", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.STUDENTINFO", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.ESSENTIALINFO", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.REVIEW", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APP.DEPOSIT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "APR.HOLD", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.DEPOSITREC", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.TREC", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.ELI", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.ESSAY", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.STUDENTAGREEMENT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.JUNSTUDENTAGREEMENT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "HLD.PGAGREEMENT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.ADVISORY", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.AMBASSADOR", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.AUTHVISIT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.BUS", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.DAYGROUP", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.HOUSING", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.INTARRIVAL", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.INTCOURSE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.INTDEPARTURE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.INTERSESSION", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.IIT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.JUNARRIVAL", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.JUNCOURSE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.JUNDEPARTURE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.MINICOURSE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.MENINGOCOCCAL", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.PARENTEVAL", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.SENARRIVAL", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.SENCOURSE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.SENDEPARTURE", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "ENR.STUDENTTECH", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.EMT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.PARKOUR.JUN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.SKYVENTURE.JUN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.TREETOP.JUN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.WARMWINDS.JUN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.INDOORROCK.JUN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.BODABORG.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.BOULDERS.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.COAST.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.GLASS.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.PADDLEBOS.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.PAINTBALL.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.SKYVENTURE.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.TREETOP.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.ADVENTOURS.INT", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.BIKETOUR.SEN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.BOSTON.SEN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.BROWNSTONE.SEN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.INDOORROCK.SEN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.PAINTBALL.SEN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"gene_production", "WV.ZOAR.SEN", "done"} => [HiveMonitor.PorticoBuffer],
  #{"photo_id", "cloudinary", "upload"} => [HiveMonitor.PorticoBuffer],
  #{"portico", "bus_route", "update"} => [HiveMonitor.KitchenHandler],
  #{"portico", "iata_code", "update"} => [HiveMonitor.KitchenHandler],
  #{"portico", "data_studio_connector", "create"} => [HiveMonitor.KitchenHandler],
  #{"portico", "courses", "definition_added"} => [HiveMonitor.CoursesHandler],
  #{"portico_gene", "task", "update"} => [HiveMonitor.GeneHandler],
  #{"portico_gene", "participant", "update"} => [HiveMonitor.GeneHandler],
  #{"portico_gene", "contact", "update"} => [HiveMonitor.GeneHandler]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
