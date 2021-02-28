defmodule HiveMonitor do
  @moduledoc """
  This app subscribes to real-time Atom updates from
  [HIVE](https://bitbucket.org/explo/hive-2), and can run scripts on the local
  machine in response to them. You would use it to avoid having to long-poll
  HIVE's REST API and instead get results in closer to real-time.

  The application can also run local scripts or Elixir functions periodically, in
  a similar way to cron, which makes it easier to keep all synchronization in one
  area. See `HiveMonitor.CronServer` for details of how to set that up.

  # Setup

  You'll want to update `config/config.exs` in your app/deployment with some API
  token variables:

      # Monitor-specific setup
      config :hive_monitor,
        hive_socket_token: "your token",
        default_chat_url: "https://chat.googleapis.com/somethin"
        
      # We also need to configure HIVE service, natch.
      config :hive_service,
        hive_api_token: "your token"

  There are a few other possible/semi-optional configuration variables
  in this system:

      config :hive_monitor,
        application_name: "can_be_customized",
        crons: "output of HiveMonitor.CronServer.get_config()",
        # The amount of time within which your initial batch of Crons will get
        # randomly started:
        cron_init_spread: :timer.minutes(3),
        # Set this to `true` if you don't want system alerts going out over chat
        disable_chat_alerts: false,
        # Set this to `true` if you don't use the PorticoBuffer
        disable_portico_buffer: false,
        router_config: "output of HiveMonitor.Router.get_config()"

  Check the related modules for more details about how to preconfigure/save
  triplet/module maps and "Cron" jobs.
  """

  use Application

  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Logger.info(fn -> "#{application_name()} starting HIVE monitoring" end)
    HiveMonitor.Supervisor.start_link()
  end

  @doc """
  The name of this application, for the purpose of posting HIVE atom receipt,
  search, etc.
  """
  def application_name do
    Application.get_env(:hive_monitor, :application_name) || "hive_monitor"
  end
end
