defmodule HiveClient.PortalHandler do
  @portal_token 'dd674122358db45f7a1f76e11328ed20'
  @portal_url 'https://portal.explo.org/hive/incoming_atoms'
  #@portal_url 'http://localhost:3000/hive/incoming_atoms'

  def handle_atom(atom) when is_map(atom) do
    atom_json = "#{atom |> Poison.encode! |> URI.encode}"
    body = "atom=#{atom_json}&portal_token=#{@portal_token}"
    headers = [
        "User-Agent": "HIVE Client",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    HTTPotion.post @portal_url, [body: body, headers: headers]
  end
end
