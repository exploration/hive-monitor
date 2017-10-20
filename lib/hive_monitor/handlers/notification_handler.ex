defmodule HiveMonitor.NotificationHandler do
  @behaviour HiveMonitor.Handler

  @moduledoc """
    This module is designed to retrieve generic notifications that come from
    any system. It expects atom data in the format:

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

  @doc """
    Inspect the atom for information about what types of notifications to send,
    then route to the appropriate system (SMS, Email, Chat).
  """
  def handle_atom(atom) when is_map(atom) do
    {:ok, data} = Poison.decode(atom["data"])
    run_if_not_empty(data, "chat_handles", :send_chat_notifications)
    run_if_not_empty(data, "sms_numbers", :send_sms_notifications)
    run_if_not_empty(data, "emails", :send_email_notifications)
    true
  end

  @doc false
  def send_chat_notifications(data) do
    message = data["message"]
    HiveMonitor.Util.HipChat.send_notification(
      message,
      from: data["from"], 
      mentions: data["chat_handles"],
      room: data["room"]
    )
  end

  @doc false
  def send_email_notifications(data) do
    message = data["message"]
    email_list = data["emails"]
    HiveMonitor.Util.Mandrill.send_email(
      message, email_list, from: data["from"], subject: data["subject"]
    )
  end

  @doc false
  def send_sms_notifications(_data) do
  end


  defp run_if_not_empty(data, key, function) do
    {:ok, values} = Map.fetch(data, key)
    if is_list(values) do
      count = Enum.count(values) > 0
      if(count > 0, do: apply(__MODULE__, function, [data]))
    end
  end

end

