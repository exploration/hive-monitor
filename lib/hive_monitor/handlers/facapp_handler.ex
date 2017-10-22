defmodule HiveMonitor.FacAppHandler do
  alias HiveMonitor.Handler
  @behaviour Handler

  @api_token '29797ffedcfbfb0e855d19972ae1656d1b8d5dbcf9602a59823fa688e'
  @api_url 'http://facapp.lab.explo.org/hive/incoming_atoms'

  def handle_atom(atom) when is_map(atom) do
    atom_json = Handler.encode_params(atom)
    body = "atom=#{atom_json}&api_token=#{@api_token}"
    headers = [
        "User-Agent": "HIVE Monitor",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    HTTPoison.post(@api_url, body, headers)

    true
  end
end
