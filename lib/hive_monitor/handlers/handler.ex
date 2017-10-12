defmodule HiveMonitor.Handler do
  @moduledoc """
    Hive Monitor defines a "Handler" as "a module that can take a HIVE atom and
    do something useful with it." As such, a Handler really only needs one
      function: `handle_atom`.
  """

  @doc "Take an atom from HIVE in realtime, and send it somewhere else."
  @callback handle_atom(map) :: boolean
end
