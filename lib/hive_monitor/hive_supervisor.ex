defmodule HiveMonitor.HiveSupervisor do
  @moduledoc """
  Handle processes related to HIVE-specific parsing.
  """

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init(
      [
        # The router takes care of handing incoming atoms from the HIVE
        # SocketClient
        HiveMonitor.Router,

        # The CronServer handles any system tasks that we want to run on a
        # periodic schedule.
        HiveMonitor.CronServer,

        # The PorticoBuffer is an EXPLO-specific GenServer that handles
        # sending atoms to our Portico system at a rate it can handle.
        HiveMonitor.Handlers.PorticoBuffer,

        # The StagnantAtomChecker keeps a list of any atoms that remain
        # in the `Router.handle_missed_atoms()` queue from one call
        # to the next.
        HiveMonitor.StagnantAtomChecker
      ],
      strategy: :one_for_one
    )
  end
end
