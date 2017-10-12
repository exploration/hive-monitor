defmodule HiveMonitor.FacAppHandler do
  @api_token '29797ffedcfbfb0e855d19972ae1656d1b8d5dbcf9602a59823fa688e'
  @api_url 'http://facapp.lab.explo.org/hive/incoming_atoms'

  def handle_atom(atom) when is_map(atom) do
    atom_json = "#{atom |> Poison.encode! |> URI.encode}"
    body = "atom=#{atom_json}&api_token=#{@api_token}"
    headers = [
        "User-Agent": "HIVE Monitor",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    HTTPotion.post @api_url, [body: body, headers: headers]
  end
end

