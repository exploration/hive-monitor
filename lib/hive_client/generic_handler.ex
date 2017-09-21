defmodule HiveClient.GenericHandler do
  def handle_atom(atom) when is_map(atom) do
    #System.cmd "/usr/bin/osascript", ["-e", "display dialog \"HIVE data received!\nApplication: #{atom["application"]}\nContext: #{atom["context"]}\nProcess: #{atom["process"]}\""]
    IO.puts("Generic Handler got the atom: (#{atom["application"]},#{atom["context"]},#{atom["process"]})")
  end
end

