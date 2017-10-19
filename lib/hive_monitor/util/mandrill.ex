defmodule HiveMonitor.Util.Mandrill do
  @api_url "https://mandrillapp.com/api/1.0/"
  @default_from_name "EXPLO Robot"
  @default_from_email "it@explo.org"
  @key "3P1HEbccxBvZ86kWOenniw"

  @doc """
    Send an email message through Mandrill. Expects a string message, and an
    array of emails in email_list.

    You can include a keyword list of options. Available options include:
    
    - `:subject` (String) - The subject of the email
    - `:from` (String) - The name to put in the FROM field for the email
  """
  def send_email(message, email_list, options \\ []) do
    {:ok, body} = Poison.encode %{
      key: @key,
      message: %{
        text: message,
        subject: Keyword.get(options, :subject) || "EXPLO Apps: Notification",
        from_name: Keyword.get(options, :from) || @default_from_name,
        from_email: @default_from_email,
        to: get_recipients(email_list)
      }
    }

    headers = [ "Content-Type": "application/json" ]
    endpoint = "#{@api_url}/messages/send.json"

    HTTPotion.post(endpoint, [body: body, headers: headers])
  end


  defp get_recipients(email_list) do
    Enum.map(email_list, fn email -> %{email: email} end)
  end

end

