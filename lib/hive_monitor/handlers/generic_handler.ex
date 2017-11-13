defmodule HiveMonitor.GenericHandler do

  @moduledoc """
  The generic case is that we send the atom to HipChat, and notify IT.
  """

  @behaviour HiveMonitor.Handler
  require Logger

  @doc false
  @impl true
  def application_name(), do: :none

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    message = "Generic Handler got the atom: (#{atom.application}" <>
        ", #{atom.context}, #{atom.process}) " <>
        "data: #{inspect atom.data}"
    Logger.info(fn -> message end)

    recipients = ["Donald"]
    {:ok, %{status_code: status_code}} = 
      ExploComm.HipChat.send_notification(notify() <> message, recipients)

    case(Enum.member?(200..299, status_code)) do
      true -> {:ok, :success}
      false -> :error
    end
  end

  defp notify do 
    admins = ["Donald"]
    admins
    |> Enum.map(fn x -> "@#{x}" end)
    |> Enum.join(" ")
    |> Kernel.<>(" ")
  end

end

