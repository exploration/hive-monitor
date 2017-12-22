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
  URL form. So we have this function here, accessible to all handlers.
  """
  @spec atom_to_uri_form(HiveAtom.t()) :: String.t()
  def atom_to_uri_form(%HiveAtom{} = atom) do
    atom
    |> atom_to_json
    |> URI.encode_www_form
  end

  defp atom_to_json(%HiveAtom{} = atom) do
    atom
    |> Map.from_struct
    |> Poison.encode!
  end

  @doc """
  For whatever reason, our realtime system might have missed HIVE atoms as they
  came across the wire. The job of this function is to grab the current list of
  triplets we should be handling, query HIVE for any atoms unseen by the
  handler application name, and handle them.

  Returns a list of the return statuses of each atom routing attempt.
  """
  @spec handle_missed_atoms() :: [any()]
  def handle_missed_atoms() do
    for {triplet, handler_list} <- Router.get_config(),
        handler <- handler_list do
      receiving_app = apply(handler, :application_name, [])
      atom_list = HiveService.get_unseen_atoms(receiving_app, triplet)

      Logger.info(fn ->
        "handling #{Enum.count(atom_list)} missed atoms from " <>
        "#{inspect triplet} for #{receiving_app}"
      end)

      Enum.each(atom_list, fn atom ->
        atom |> Map.from_struct |> Router.route
      end)
    end
  end
end
