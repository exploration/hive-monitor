defmodule HiveMonitor do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Logger.info(fn -> "Starting HIVE Monitoring" end)
    HiveMonitor.Supervisor.start_link()    
  end

  @doc """
  The name of this application, for the purpose of posting HIVE atom receipt,
  search, etc.
  """
  def application_name do
    Application.get_env(:hive_monitor, :application_name) ||
        "hive_monitor"
  end
end
