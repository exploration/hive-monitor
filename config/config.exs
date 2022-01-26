# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# In case you want to run the monitor directly, and not embedded, you can
# un-comment this HIVE setup stuff:
config :hive_monitor,
  # application_name: "can_be_customized",
  crons: [
    %{
      name: "handle_missed_atoms",
      module: HiveMonitor.Router,
      fun: :handle_missed_atoms,
      args: [],
      rate: :timer.minutes(30)
    }
    # %{
    #   name: "filemaker_quit",
    #   module: System,
    #   fun: :cmd,
    #   args: ["/Users/exploadmin/Cron/filemaker_quit.sh", []],
    #   rate: :timer.hours(2)
    # }
    # %{
    #   name: "filemaker_activate",
    #   module: System,
    #   fun: :cmd,
    #   args: ["/Users/exploadmin/Cron/filemaker_activate.sh", []],
    #   rate: :timer.minutes(1)
    # }
  ],
  # cron_init_spread: :timer.minutes(3)
  # default_chat_url: "https://chat.googleapis.com/somethin"
  # disable_chat_alerts: true,
  # disable_portico_buffer: true,
  hive_socket_token: "xaDeqPCwnwMzGSRq3RIaEgmmQR85Kmqe5Fa6vQhEqGLkMe8HW6bO7hwUJLYqj6z",
  log_unrecognized_atoms: false,
  router_config:
    %{
      # {"explo", "notification", "create"} => [HiveMonitor.Handlers.NotificationHandler],
    }

# Set these if you're using these respective handlers
# token_courses: "",
# token_gene: "",
# token_kitchen: ""

config :hive_service,
  hive_api_token: "G0iIkduflP4wMmSRO8x8KLzk1EZIYIYnIo7sl7y5GQYuQ44XCgYaMcfh7RJVHhr"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
