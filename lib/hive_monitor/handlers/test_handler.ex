defmodule HiveMonitor.TestHandler do
  @behaviour HiveMonitor.Handler

  # When testing, we merely log the atom
  def handle_atom(atom) when is_map(atom) do
    message = "Test Handler got the atom: (#{atom["application"]}, #{atom["context"]}, #{atom["process"]})"
    IO.puts message

    true
  end

end
