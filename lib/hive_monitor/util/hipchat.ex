defmodule HiveMonitor.Util.HipChat do
  @api_url "https://api.hipchat.com/v2"
  @default_room "143945" # "ROBOTS" room
  @token "AwS0F1sbBYlPPSJOWwITASwr7yslZBi9sVxJI10S"

  def send_notification(message) do
    send_notification(message, [], @default_room)
  end
  def send_notification(message, mentions) do
    send_notification(message, mentions, @default_room)
  end
  def send_notification(message, mentions, room) do
    {:ok, body} = Poison.encode %{
      from: "HIVE Monitor",
      format: "text",
      notify: true,
      message: "#{format_mentions(mentions)}#{message}"
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
