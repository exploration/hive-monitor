defmodule HiveClient.FMHandler do
  def handle_atom(atom) when is_map(atom) do
    System.cmd "/usr/bin/osascript", ["-e", "display dialog \"FileMaker data received!\nApplication: #{atom["application"]}\nContext: #{atom["context"]}\nProcess: #{atom["process"]}\""]
  end
end
