defmodule HiveMonitor.Handler do
  @moduledoc """
  Hive Monitor defines a "Handler" as "a module that can take a HIVE atom and
  do something useful with it." 

  This module defines callbacks necessary for anything that wants to be a
  handler, as well as some utility functions that get called in a lot of
  Handler contexts.
  """

  require Logger

  alias HiveMonitor.Router


  @doc """
  We need to set the application name that corresponds to each handler. For
  example, `PortalHandler` might have the application name of `portal` - that
  is, each HiveAtom originating from the Portal system would have `application:
  "portal"`. 
  """
  @callback application_name() :: String.t | :none

  @doc """
  Take a HiveAtom from HIVE in realtime, and send it somewhere else.

  Returns a boolean: `true` for it worked, `false` otherwise.
  """
  @callback handle_atom(%HiveAtom{}) :: {:ok, atom()} | :error

  
  @doc """
  We often have a need in HIVEMonitor handlers to convert an atom to an encoded
  URL parameter. So we have this function here, accessible to all handlers.
  """
  @spec atom_to_uri_query(HiveAtom.t()) :: String.t()
  def atom_to_uri_query(atom = %HiveAtom{}) do
    atom
    |> Map.from_struct
    |> Poison.encode!
    |> URI.encode_www_form
  end

  @doc """
  For whatever reason, our realtime system might have missed HIVE atoms as they
  came across the wire. The job of this function is to grab the current list of
  triplets we should be handling, query HIVE for any atoms unseen by the
  handler application name, and handle them.
  """
  @spec handle_missed_atoms() :: :ok
  def handle_missed_atoms() do
    known_triplets = Router.get_config()

    Enum.each(known_triplets, fn known_triplet ->
      {triplet, handler_list} = known_triplet

      Enum.each(handler_list, fn handler ->
        receiving_app = apply(handler, :application_name, [])
        atom_list = HiveService.get_unseen_atoms(receiving_app, triplet)

        Logger.info(fn -> 
          "handling #{Enum.count(atom_list)} missed atoms from " <>
          "#{inspect triplet} for #{receiving_app}"
        end)

        Enum.each(atom_list, fn atom -> 
          atom |> Map.from_struct |> Router.route
        end)
      end)
    end)
  end
end
