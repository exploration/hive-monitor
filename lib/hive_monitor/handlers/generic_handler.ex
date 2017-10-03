defmodule HiveMonitor.GenericHandler do
  @hipchat_api_url "https://api.hipchat.com/v2"
  @hipchat_room "143945"
  @hipchat_token "AwS0F1sbBYlPPSJOWwITASwr7yslZBi9sVxJI10S"
  @recipients ["Donald"]

  # The generic case is that we send the atom to HipChat
  def handle_atom(atom) when is_map(atom) do
    message = "Generic Handler got the atom: (#{atom["application"]}, #{atom["context"]}, #{atom["process"]})"
    IO.puts message
    body = "from=HIVE Monitor&format=text&notify=true&message=#{format_recipients()} #{message}"
      |> URI.encode
    headers = [
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer #{@hipchat_token}"
    ]
    HTTPotion.post "#{@hipchat_api_url}/room/#{@hipchat_room}/notification", 
        [body: body, headers: headers]
  end

  defp format_recipients do
    @recipients
      |> Enum.map(&("@" <> &1))
      |> Enum.join(" ")
  end
end

