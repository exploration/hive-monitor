defmodule HiveMonitor.Handlers.NotificationHandler do
  @moduledoc """
  This module is designed to retrieve generic notifications that come
  from any system. It expects atom.data in the format:

      {
        message: String (required)

        sms_numbers: [String] (optional list of sms phone numbers of recipients)

        emails: [String] (optional list of email addresses of recipients)
        from: String (optional name of the sender)
        subject: String (optional email subject line)
      }
  """

  @behaviour HiveMonitor.Handler
  require Logger
  alias ExploComm.{Mandrill, Twilio}

  @doc false
  @impl true
  def application_name, do: HiveMonitor.application_name()

  @doc """
  Inspect the atom for information about what types of notifications
  to send, then route to the appropriate system (SMS, Email).
  """
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    case Jason.decode(atom.data) do
      {:ok, data} ->
        run_if_not_empty(
          data,
          sms_numbers: :send_sms_notifications,
          emails: :send_email_notifications
        )

      {:error, reason} ->
        Logger.error(fn ->
          "#{HiveMonitor.application_name()} notification JSON error: #{inspect(reason)}"
        end)

        :error
    end

    HiveService.delete_atom(atom.id)

    true
  end

  @doc false
  def send_email_notifications(data) do
    {:ok, response} =
      Mandrill.send_email(
        data["message"],
        data["emails"],
        from: data["from"],
        subject: data["subject"]
      )

    status = parse_status_code(response.status_code)

    if status == {:ok, :sent} do
      Logger.info(fn -> "#{HiveMonitor.application_name()} email notification(s) sent to #{inspect data["emails"]}" end)
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
        Logger.info(fn -> "#{HiveMonitor.application_name()} sms notification(s) sent to #{inspect number_list}" end)
        {:ok, :sent}

      false ->
        {:error, :send_sms}
    end
  end

  defp parse_status_code(status_code) do
    case status_code >= 200 && status_code < 300 do
      true -> {:ok, :sent}
      false -> {:error, :send_notification}
    end
  end

  # Run given messaging functions from the atom data. The way that this works
  # is: Given some data, and a list of key/function tuples, attempt to run each
  # of the functions if the key is present in the data.
  #
  # Returns a list of status tuples, one for each key/function tuple sent.
  defp run_if_not_empty(data, key_function_tuples) do
    Enum.map(key_function_tuples, fn {key, function} ->
      key = Atom.to_string(key)

      with {:ok, recipients} <- Map.fetch(data, key),
           true <- is_list(recipients),
           recipients <- strip_empty_strings(recipients),
           true <- Enum.count(recipients) > 0 do
        apply(__MODULE__, function, [data])
      else
        false -> {:error, :empty_recipients}
        _ -> {:error, :invalid_recipients}
      end
    end)
  end

  defp strip_empty_strings(list) when is_list(list) do
    Enum.filter(list, fn x -> x != "" end)
  end
end
