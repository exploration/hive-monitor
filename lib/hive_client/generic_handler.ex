defmodule HiveClient.GenericHandler do
  def handle_atom(atom) when is_map(atom) do
    System.cmd "/usr/bin/osascript", ["-e", "display dialog \"HIVE data received!\nApplication: #{atom["application"]}\nContext: #{atom["context"]}\nProcess: #{atom["process"]}\""]
  end
end

