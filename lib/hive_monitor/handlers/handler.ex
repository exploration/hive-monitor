defmodule HiveMonitor.Handler do
  @moduledoc """
  Hive Monitor defines a "Handler" as "a module that can take a HIVE atom and
  do something useful with it." As such, a Handler really only needs one
    function: `handle_atom`.
  """

  alias Explo.HiveAtom


  @doc """
  We need to set the application name that corresponds to each handler. For
  example, `PortalHandler` might have the application name of `portal` - that
  is, each HiveAtom originating from the Portal system would have `application:
  "portal"`. 
  """
  @callback application_name :: String.t | :none

  @doc """
  Take a HiveAtom from HIVE in realtime, and send it somewhere else.

  Returns a boolean: `true` for it worked, `false` otherwise.
  """
  @callback handle_atom(%HiveAtom{}) :: boolean

  
  @doc """
  We often have a need in HIVEMonitor handlers to convert an atom to an encoded
  URL parameter. So we have this function here, accessible to all handlers.
  """
  def atom_to_uri_query(atom = %HiveAtom{}) do
    atom
    |> Map.from_struct
    |> Poison.encode!
    |> URI.encode_www_form
  end

  @doc """
  For whatever reason, our realtime system might have missed HIVE atoms as they
  came across the wire. The job of this function is to grab the current list of
  triplets we should be handling, query HIVE for any unseen atoms, and handle
  them.
  """
  def handle_missed_atoms do
    known_triplets = HiveMonitor.Router.known_triplets()
    Enum.each(known_triplets, fn triplet ->
      IO.inspect triplet
      #Explo.HiveService.get_unseen_atoms(
    end)
  end
end
