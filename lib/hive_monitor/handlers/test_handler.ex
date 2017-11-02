defmodule HiveMonitor.TestHandler do

  @moduledoc """
  Utility handler used during testing.
  """

  @behaviour HiveMonitor.Handler
  require Logger

  @doc false
  def application_name(), do: :none

  @doc """
  When testing, we merely log the atom
  """
  def handle_atom(%Explo.HiveAtom{} = atom) do
    message = "Test Handler: #{inspect atom}"
    Logger.debug(fn -> message end)
    
    {:ok, :success}
  end

end
