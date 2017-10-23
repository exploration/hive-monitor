defmodule HiveMonitor.FMHandler do
  
  @moduledoc """
  Forward an atom along to Portico's "incoming atom" endpoint.
  """

  alias HiveMonitor.Handler

  @behaviour Handler

  @script_name "pub - receive new atom from HIVE (atom_json)"
  @server_url "fmp://minerva.explo.org/hive_data"
  

  @doc false
  def application_name(), do: "portico"

  @doc """
  FileMaker/Portico atoms are passed to a FM script, which brings them into the
  hive_data DB and passes them along to the appropriate handler within Portico.
  """
  def handle_atom(atom) do
    url = "#{@server_url}" <>
      "?script=#{URI.encode(@script_name)}" <>
      "&param=#{Handler.atom_to_uri_query(atom)}"
    System.cmd "/usr/bin/open", [url]

    true
  end
end
