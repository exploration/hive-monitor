defmodule HiveMonitor.GenericHandler do

  @moduledoc """
  The generic case is that we send the atom to HipChat, and notify IT.
  """

  require Logger

  @behaviour HiveMonitor.Handler

  @doc false
  def application_name, do: :none

  @doc false
  def handle_atom(atom) do
    recipients = ["Donald"]
    message = "Generic Handler got the atom: (#{atom.application}" <>
        ", #{atom.context}, #{atom.process})"

    Logger.info(message)
    Explo.Util.HipChat.send_notification(message, recipients)
    true
  end

end

