defmodule HiveClient.FMHandler do
  @script_name "pub - receive new atom from HIVE (atom_json)"
  @server_url "fmp://minerva.explo.org/hive_data"
  
  @doc """
  FileMaker atoms are passed to a FM script, which brings them into the
  hive_data DB and passes them along to the appropriate handler within Portico.
  """
  def handle_atom(atom) when is_map(atom) do
    url = "#{@server_url}" <>
      "?script=#{URI.encode(@script_name)}" <>
      "&param=#{atom |> Poison.encode! |> URI.encode}"
    System.cmd "/usr/bin/open", [url]
  end
end
