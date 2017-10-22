defmodule HiveMonitor.PortalHandler do
  alias HiveMonitor.Handler
  @behaviour Handler

  @portal_token 'dd674122358db45f7a1f76e11328ed20'
  @portal_url 'https://portal.explo.org/hive/incoming_atoms'

  def handle_atom(atom) when is_map(atom) do
    atom_json = Handler.encode_params(atom)
    body = "atom=#{atom_json}&portal_token=#{@portal_token}"
    headers = [
        "User-Agent": "HIVE Monitor",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    HTTPoison.post @portal_url, body, headers

    true
  end
end
