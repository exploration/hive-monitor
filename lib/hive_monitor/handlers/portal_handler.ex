defmodule HiveMonitor.PortalHandler do
  
  @moduledoc """
  Forward an atom to the Portal's incoming_atom endpoint.
  """

  alias HiveMonitor.Handler
  @behaviour Handler

  @portal_token 'dd674122358db45f7a1f76e11328ed20'
  @portal_url 'https://portal.explo.org/hive/incoming_atoms'

  @doc false
  @impl true
  def application_name(), do: "portal_production"

  @doc false
  @impl true
  def handle_atom(%Explo.HiveAtom{} = atom) do
    atom_encoded = Handler.atom_to_uri_query(atom)

    body = "atom=#{atom_encoded}&portal_token=#{@portal_token}"
    headers = [
        "User-Agent": "HIVE Monitor",
        "Content-Type": "application/x-www-form-urlencoded"
    ]

    {:ok, %{status_code: status_code}} = 
      HTTPoison.post @portal_url, body, headers

    case(Enum.member?(200..299, status_code)) do
      true -> {:ok, :success}
      false -> :error
    end
  end
end
