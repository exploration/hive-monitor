# HIVE Monitor

This app subscribes to real-time Atom updates from
[HIVE](https://bitbucket.org/explo/hive-2), and can run scripts on the local
machine in response to them. You would use it to avoid having to long-poll
HIVE's REST API and instead get results in closer to real-time.

The application can also run local scripts or Elixir functions periodically, in
a similar way to cron, which makes it easier to keep all synchronization in one
area. See `CronServer` for details of how to set that up.


# Setup

You'll probably want to update `config/config.exs` with some API token
variables:

    config :hive_monitor,
      hive_socket_token: "your token"

    config :explo,
      hive_api_token: "your token",
      hipchat_api_token: "your token",
      mandrill_api_key: "your key"
      twilio_api_token: "your token"

These can also be set as environment variables in ALL_CAPS (eg
`HIVE_SOCKET_TOKEN` etc.).

There are a few other possible/semi-optional configuration variables in this
system:

    config :hive_monitor,
      application_name: "can_be_customized",
      router_config: "output of HiveMonitor.Router.get_config()"
      crons: "output of HiveMonitor.CronServer.get_config()",
      # The amount of time within which your initial batch of Crons will get
      # randomly started:
      cron_init_spread: :timer.minutes(3)

Check the related modules for more details about how to preconfigure/save
triplet/module maps and "Cron" jobs.
