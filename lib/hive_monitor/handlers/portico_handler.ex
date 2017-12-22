defmodule HiveMonitor.PorticoHandler do

  @moduledoc """
  Forward an atom along to Portico's "incoming atom" endpoint.
  """

  alias HiveMonitor.Handler

  @behaviour Handler

  @script_name "pub - receive new atom from HIVE (atom_json)"
  @server_url "fmp://minerva.explo.org/hive_data"

  @doc false
  @impl true
  def application_name(), do: "portico"

  @doc """
  FileMaker/Portico atoms are passed to a FM script, which brings them into the
  hive_data DB and passes them along to the appropriate handler within Portico.
  """
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    url = "#{@server_url}" <>
      "?script=#{URI.encode(@script_name)}" <>
      "&param=#{atom_to_fm_query(atom)}"
    System.cmd "/usr/bin/open", [url]

    {:ok, :fine}
  end

  # FileMaker can't handle "+"es in passed queries, but otherwise handles them
  # like form data...
  defp atom_to_fm_query(%HiveAtom{} = atom) do
    atom
    |> Handler.atom_to_uri_form
    |> String.replace("+", "%20")
  end
end
