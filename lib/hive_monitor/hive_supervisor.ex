defmodule HiveMonitor.HiveSupervisor do
  @moduledoc """
  Handle processes related to HIVE-specific parsing.
  """

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      HiveMonitor.Router,
      HiveMonitor.CronServer,
      HiveMonitor.StagnantAtomChecker
    ]

    children =
      if Application.get_env(:hive_monitor, :disable_portico_buffer) do
        children
      else
        children ++ [HiveMonitor.Handlers.PorticoBuffer]
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
