defmodule HiveMonitor.TestHandler do

  @moduledoc """
  Utility handler used during testing.
  """

  @behaviour HiveMonitor.Handler
  require Logger

  # When testing, we merely log the atom
  def handle_atom(atom) do
    message = "Test Handler got the atom: (#{atom.application}, #{atom.context}, #{atom.process})"
    Logger.info(message)

    true
  end

end
