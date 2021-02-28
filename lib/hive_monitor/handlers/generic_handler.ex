defmodule HiveMonitor.Handlers.GenericHandler do
  @moduledoc """
  The generic case is merely to log the atom
  """

  @behaviour HiveMonitor.Handler

  require Logger

  @doc false
  @impl true
  def application_name, do: :none

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    message =
      "Generic Handler got the atom: (#{atom.application}" <>
        ", #{atom.context}, #{atom.process}) data: #{inspect(atom.data)}"

    Logger.info(fn -> message end)

    {:ok, :success}
  end
end
