defmodule HiveMonitor.NotificationHandler do
  @behaviour HiveMonitor.Handler

  @moduledoc """
    This module is designed to retrieve generic notifications that come from any system. It expects atom data in the format:

        {
          message: String
          from: String (optional name of the sender)

          chat_handles: [String] (optional list of chat handles of recipients)
          room: String (optional chatroom to post into)

          sms_numbers: [String] (optional list of sms phone numbers of recipients)

          emails: [String] (optional list of email addresses of recipients)
          subject: String (optional email subject line)
        }
  """

  def handle_atom(atom) when is_map(atom) do
    {:ok, data} = Poison.decode(atom["data"])
    run_if_not_empty(data, "chat_handles", :send_chat_notifications)
    run_if_not_empty(data, "sms_numbers", :send_sms_notifications)
    run_if_not_empty(data, "emails", :send_email_notifications)
    true
  end

  defp run_if_not_empty(data, key, function) do
    with {:ok, values} <- Map.fetch(data, key),
        true = Enum.count(values) > 0,
        do: apply(__MODULE__, function, [data])
  end

  defp send_chat_notifications(data) do
    IO.puts "Sending a notification message: #{inspect data}"

    message = data["message"]
    HiveMonitor.Util.HipChat.send_notification(
      message, from: data["from"], mentions: data["chat_handles"], room: data["room"]
    )
  end

  defp send_email_notifications(_data) do
  end

  defp send_sms_notifications(_data) do
  end
end


