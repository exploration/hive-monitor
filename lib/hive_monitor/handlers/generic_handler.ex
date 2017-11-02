defmodule HiveMonitor.GenericHandler do

  @moduledoc """
  The generic case is that we send the atom to HipChat, and notify IT.
  """

  @behaviour HiveMonitor.Handler
  require Logger

  @doc false
  def application_name(), do: :none

  @doc false
  def handle_atom(%Explo.HiveAtom{} = atom) do
    message = "Generic Handler got the atom: (#{atom.application}" <>
        ", #{atom.context}, #{atom.process})"
    Logger.info(fn -> message end)

    recipients = ["Donald"]
    {:ok, %{status_code: status_code}} = 
      Explo.Util.HipChat.send_notification(message, recipients)

    case(Enum.member?(200..299, status_code)) do
      true -> {:ok, :success}
      false -> :error
    end
  end

end

