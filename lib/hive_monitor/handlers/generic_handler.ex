defmodule HiveMonitor.GenericHandler do
  @behaviour HiveMonitor.Handler

  @doc """
  The generic case is that we send the atom to HipChat.
  """
  def handle_atom(atom) when is_map(atom) do
    recipients = ["Donald"]
    message = "Generic Handler got the atom: (#{atom["application"]}" <>
        ", #{atom["context"]}, #{atom["process"]})"

    IO.puts(message)
    Explo.Util.HipChat.send_notification(message, recipients)
    true
  end

end

