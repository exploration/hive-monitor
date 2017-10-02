defmodule HiveMonitor.HiveSupervisor do
  use Supervisor

  @moduledoc """
    This supervisor handles all processes related to HIVE-specific parsing,
    such as the HIVE atom router, and the CRON server for keeping external
    processes in sync.
  """

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([
      # The router takes care of handing incoming atoms from the HIVE
      # SocketClient
      HiveMonitor.Router,

      # Place any CRON commands you wish to run here:
      cron_child("/bin/echo", ["ping"], :timer.seconds(60), true, "test1"),
    ], strategy: :one_for_one)
  end

  defp cron_child(cmd, args, rate, run_on_start, id) do
    Supervisor.child_spec({ 
        HiveMonitor.CronServer, 
        %HiveMonitor.CronServer.State{ 
            cmd: cmd, args: args, rate: rate, run_on_start: run_on_start} 
        }, 
        id: id
    )
  end
end

