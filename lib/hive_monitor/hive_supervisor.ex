defmodule HiveMonitor.HiveSupervisor do
  @moduledoc """
  This supervisor handles all processes related to HIVE-specific parsing,
  such as the HIVE atom router, and the CRON server for keeping external
  processes in sync.
  """

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([
      # The router takes care of handing incoming atoms from the HIVE
      # SocketClient
      HiveMonitor.Router,
      # The CronServer handles any system tasks that we want to run on a
      # periodic schedule.
      HiveMonitor.CronServer
    ], strategy: :one_for_one)
  end
end

