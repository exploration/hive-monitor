defmodule HiveMonitor.Handler do
  @moduledoc """
  Hive Monitor defines a "Handler" as "a module that can take a HIVE atom and
  do something useful with it." As such, a Handler really only needs one
    function: `handle_atom`.
  """

  alias Explo.HiveAtom


  @doc """
  Take a HiveAtom from HIVE in realtime, and send it somewhere else.

  Returns a boolean: `true` for it worked, `false` otherwise.
  """
  @callback handle_atom(%HiveAtom{}) :: boolean


  def atom_to_uri_query(atom = %HiveAtom{}) do
    atom
    |> Map.from_struct
    |> Poison.encode!
    |> URI.encode_www_form
  end
end
