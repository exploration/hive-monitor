defmodule HiveMonitor.FacAppHandler do
  
  @moduledoc """
  Forward an atom to the FacApp (v2) `incoming_atoms` endpoint.
  """

  alias HiveMonitor.Handler

  @behaviour Handler

  # TODO: move this token out of the source code
  @api_token '29797ffedcfbfb0e855d19972ae1656d1b8d5dbcf9602a59823fa688e'
  @api_url 'http://facapp.lab.explo.org/hive/incoming_atoms'


  @doc false
  def application_name(), do: "facapp"

  @doc false
  def handle_atom(atom) when is_map(atom) do
    atom_encoded = Handler.atom_to_uri_query(atom)
    body = "atom=#{atom_encoded}&api_token=#{@api_token}"
    headers = [
        "User-Agent": "HIVE Monitor",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    HTTPoison.post(@api_url, body, headers)

    true
  end
end
