defmodule HiveMonitor.NotificationHandler do
  @behaviour HiveMonitor.Handler

  @moduledoc """
    This module is designed to retrieve generic notifications that come from any system. It expects atom data in the format:

        {
          message: String
          chat_handles: [String] (optional list of chat handles of recipients)
          emails: [String] (optional list of email addresses of recipients)
          sms_numbers: [String] (optional list of sms phone numbers of recipients)
          room: String (optional chatroom to post into)
          subject: String (optional email subject line)
        }
  """

  def handle_atom(atom) when is_map(atom) do
    {:ok, data} = Poison.decode(atom["data"])
    send_chat_notifications(data)    
    send_email_notifications(data)
    send_sms_notifications(data)
    true
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


