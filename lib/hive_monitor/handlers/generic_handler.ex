defmodule HiveMonitor.GenericHandler do
  @behaviour HiveMonitor.Handler

  # The generic case is that we send the atom to HipChat
  def handle_atom(atom) when is_map(atom) do
    recipients = ["Donald"]
    message = "Generic Handler got the atom: (#{atom["application"]}" <>
        ", #{atom["context"]}, #{atom["process"]})"

    IO.puts(message)
    HiveMonitor.Util.HipChat.send_notification(message, recipients)
    true
  end

end

