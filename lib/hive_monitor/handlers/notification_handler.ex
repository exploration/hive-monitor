defmodule HiveMonitor.NotificationHandler do

  @moduledoc """
  This module is designed to retrieve generic notifications that come from
  any system. It expects atom.data in the format:

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

  @behaviour HiveMonitor.Handler
  require Logger
  alias Explo.HiveService
  alias Explo.Util.{HipChat, Mandrill, Twilio}
  
  @doc false
  def application_name(), do: HiveMonitor.application_name()

  @doc """
    Inspect the atom for information about what types of notifications to send,
    then route to the appropriate system (SMS, Email, Chat).
  """
  def handle_atom(atom) do
    case Poison.decode(atom.data) do
      {:ok, data} ->
        status_list = run_if_not_empty( 
          data, 
          "chat_handles": :send_chat_notifications,
          "sms_numbers": :send_sms_notifications,
          "emails": :send_email_notifications
        )
        put_receipt(atom, status_list)
      error -> Logger.error(fn -> inspect(error) end)
    end
  end

  @doc false
  def send_chat_notifications(data) do
    message = data["message"]
    {:ok, response} = HipChat.send_notification(
      message,
      from: data["from"], 
      mentions: data["chat_handles"],
      room: data["room"]
    )
    status = parse_status_code(response.status_code)
    if status == {:ok, :sent} do
      Logger.info(fn -> "chat notification(s) sent" end)
    end
    status
  end

  @doc false
  def send_email_notifications(data) do
    message = data["message"]
    email_list = data["emails"]
    {:ok, response} = Mandrill.send_email(
      message, email_list, from: data["from"], subject: data["subject"]
    )
    status = parse_status_code(response.status_code)
    if status == {:ok, :sent} do
      Logger.info(fn -> "email notification(s) sent" end)
    end
    status
  end

  @doc false
  def send_sms_notifications(data) do
    message = data["message"] 
    number_list = data["sms_numbers"]
    status_list =
      Enum.map(number_list, fn number ->
        {:ok, response} = Twilio.send_sms(message, number)
        parse_status_code(response.status_code)
      end)
    case Enum.any?(status_list, &({:ok, :sent} == &1)) do
      true -> 
        Logger.info(fn -> "sms notification(s) sent" end)
        {:ok, :sent}
      false -> {:error, :send_sms}
    end
  end


  defp strip_empty_strings(list) when is_list(list) do
    Enum.filter(list, fn x -> x != "" end)
  end

  defp parse_status_code(status_code) do
    case status_code >= 200 && status_code < 300 do
      true -> {:ok, :sent}
      false -> {:error, :send_notification}
    end
  end

  defp put_receipt(atom, status_list) do
    with notifications_went_through? <-
          Enum.any?(status_list, fn {status, _} -> status == :ok end),
        no_valid_statuses? <- Enum.all?(status_list, 
          fn stat -> stat == {:error, :empty_recipients} end
        ),
        put_receipt? <- is_integer(atom.id) &&
          (no_valid_statuses? || notifications_went_through?) do

      if put_receipt? do
        HiveService.put_receipt(atom.id, HiveMonitor.application_name())    
      end
    end
  end

  # Given some data, and a list of key/function tuples, attempt to run each of
  # the functions if the key is present in the data.
  #
  # Returns a list of status tuples, one for each key/function tuple sent.
  defp run_if_not_empty(data, key_function_tuples) do
    Enum.map(key_function_tuples, fn {key, function} ->
      key = Atom.to_string(key)
      case Map.fetch(data, key) do
        {:ok, recipients} ->
          case is_list(recipients) do
            true ->
              recipients = strip_empty_strings(recipients)
              case Enum.count(recipients) > 0 do
                true -> apply(__MODULE__, function, [data])
                false -> {:error, :empty_recipients}
              end
            false -> {:error, :invalid_recipients}
          end
        :error -> {:error, :empty_recipients}
      end
    end)
  end

end

