defmodule HiveMonitor.GenericHandler do

  @moduledoc """
  The generic case is that we send the atom to HipChat, and notify IT.
  """

  @behaviour HiveMonitor.Handler

  require Logger

  alias ExploComm.HipChat

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

    {:ok, %{status_code: status_code}} =
      HipChat.send_notification(
        notify() <> message, mentions: recipients()
      )

    case(Enum.member?(200..299, status_code)) do
      true -> {:ok, :success}
      _ -> :error
    end
  end

  defp notify() do
    admins = ["Donald"]
    admins
    |> Enum.map(fn x -> "@#{x}" end)
    |> Enum.join(" ")
    |> Kernel.<>(" ")
  end

  defp recipients() do
    Application.get_env(:hive_monitor, :default_chat_recipients) || ["Donald"]
  end

end
