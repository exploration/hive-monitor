# HIVE Monitor

This app subscribes to real-time Atom updates from [HIVE](https://bitbucket.org/explo/hive-2), and can run scripts on the local machine in response to them. You would use it to avoid having to long-poll HIVE's REST API and instead get results in closer to real-time.

The application can also run local scripts or Elixir functions periodically, in a similar way to cron, which makes it easier to keep all synchronization in one area. See `CronServer` for details of how to set that up.


# Setup

You'll probably want to update `config/config.exs` with some API token variables:

    config :hive_monitor,
      hive_socket_token: "your token"

    config :explo,
      hive_api_token: "your token",
      hipchat_api_token: "your token",
      mandrill_key: "your key"

These can also be set as environment variables in ALL_CAPS (eg `HIVE_SOCKET_TOKEN` etc.).
