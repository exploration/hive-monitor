defmodule HiveClient.PortalHandler do
  def handle_atom(atom) when is_map(atom) do
    #System.cmd "/usr/bin/osascript", ["-e", "display dialog \"Portal data received!\nApplication: #{atom["application"]}\nContext: #{atom["context"]}\nProcess: #{atom["process"]}\""]
    IO.puts("Portal Handler got the atom")
  end
end
