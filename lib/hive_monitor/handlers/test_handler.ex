defmodule HiveMonitor.TestHandler do
  @moduledoc """
  Utility handler used during testing.
  """

  @behaviour HiveMonitor.Handler
  require Logger

  @doc false
  @impl true
  def application_name, do: :none

  @doc """
  When testing, we merely log the atom
  """
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    message = "Test Handler: #{inspect(atom)}"
    Logger.debug(fn -> message end)

    {:ok, :success}
  end
end
