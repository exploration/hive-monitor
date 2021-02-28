defmodule HiveMonitor.Handler do
  @moduledoc """
  A "Handler" is a module that can take a HIVE atom and do something useful
  with it. 

  This module defines callbacks necessary for anything that wants to be a
  handler, as well as some utility functions that get called in a lot of
  Handler contexts.
  """

  require Logger

  @doc """
  Set the application name that corresponds to each handler. 

  For example, `GeneHandler` might have the application name of `gene` -
  that is, each HiveAtom originating from the GENE system would have
  `application: "gene"`. 
  """
  @callback application_name() :: String.t() | :none

  @doc """
  Take a `%HiveAtom{}` from HIVE in realtime, and send it somewhere else.

  Returns a boolean: `true` for it worked, `false` otherwise.
  """
  @callback handle_atom(%HiveAtom{}) :: {:ok, atom()} | :error

  @doc """
  Convert an atom to an encoded URL form, typically for POSTs to REST apis.

  We have this function here to be accessible to all handlers (sort of like
  inheritance, get it?)
  """
  @spec atom_to_uri_form(HiveAtom.t()) :: String.t()
  def atom_to_uri_form(%HiveAtom{} = atom) do
    atom
    |> Map.from_struct()
    |> Jason.encode!()
    |> URI.encode_www_form()
  end
end
