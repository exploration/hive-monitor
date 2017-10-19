defmodule HiveMonitor.Util.HipChat do
  @api_url "https://api.hipchat.com/v2"
  @default_room "143945" # "ROBOTS" room
  @token "AwS0F1sbBYlPPSJOWwITASwr7yslZBi9sVxJI10S"

  @doc """
    Send a notification through HipChat.

    You can include a keyword list of options. Available options include:
    
    - `:from` (String) - The name of the sender
    - `:mentions` ([String]) - The HipChat mention names of people who should receive a notification
    - `:room` (Integer) - The ID of the room to which to post the message
  """
  def send_notification(message, options \\ []) do
    mentions = format_mentions(Keyword.get(options, :mentions, []))
    room = Keyword.get(options, :room) || @default_room

    {:ok, body} = Poison.encode %{
      from: Keyword.get(options, :from) || "HIVE Monitor",
      format: "text",
      notify: true,
      message: "#{mentions}#{message}"
    }
    headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer #{@token}"
    ]
    endpoint = "#{@api_url}/room/#{room}/notification"

    HTTPotion.post(endpoint, [body: body, headers: headers])
  end

  defp format_mentions(mentions) when is_list(mentions) do
    mentions
    |> Enum.map(fn recipient -> "@#{recipient}" end)
    |> Enum.join(" ")
    |> String.replace_suffix("", " ")
  end
end
