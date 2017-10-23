defmodule HiveMonitor.PortalHandler do
  
  @moduledoc """
  Forward an atom to the Portal's incoming_atom endpoint.
  """

  alias HiveMonitor.Handler

  @behaviour Handler

  @portal_token 'dd674122358db45f7a1f76e11328ed20'
  @portal_url 'https://portal.explo.org/hive/incoming_atoms'

  @doc false
  def application_name(), do: "portal_production"

  @doc false
  def handle_atom(atom) do
    atom_encoded = Handler.atom_to_uri_query(atom)

    body = "atom=#{atom_encoded}&portal_token=#{@portal_token}"
    headers = [
        "User-Agent": "HIVE Monitor",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    HTTPoison.post @portal_url, body, headers

    true
  end
end
