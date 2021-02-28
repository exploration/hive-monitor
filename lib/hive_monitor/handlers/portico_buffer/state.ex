defmodule HiveMonitor.Handlers.PorticoBuffer.State do
  @moduledoc """
  State management for `HiveMonitor.Handlers.PorticoBuffer`
  """

  defstruct rate: :timer.seconds(10), atoms: MapSet.new()

  @typedoc """
  The state of the PorticoBuffer has a rate (at which Portico receives atoms), and a list of atoms remaining to parse.
  """
  @type t :: %__MODULE__{
          rate: integer(),
          atoms: MapSet.t(HiveAtom.t())
        }
end
