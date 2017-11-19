defmodule HiveMonitor.SocketSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([
      HiveMonitor.SocketClient
    ], strategy: :one_for_one)
  end
end
