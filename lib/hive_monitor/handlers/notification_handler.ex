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
    message = data["message"]
    with chat_handles = data["chat_handles"] do
      IO.puts "Sending a notification message to #{inspect chat_handles}"
      case Map.fetch(data, "room") do
        :error -> HiveMonitor.Util.HipChat.send_notification(message, chat_handles)
        room -> HiveMonitor.Util.HipChat.send_notification(message, chat_handles, room)
      end
    end
  end

  defp send_email_notifications(_data) do
  end

  defp send_sms_notifications(_data) do
  end
end


