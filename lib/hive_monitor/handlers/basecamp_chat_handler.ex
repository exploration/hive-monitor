defmodule HiveMonitor.BasecampChatHandler do
  @moduledoc """
  Basecamp "bot" for chats.

  Infers "commands" from the given chatbot text, and sends responses via Basecamp's API.

  Read <https://github.com/basecamp/bc3-api/blob/master/sections/chatbots.md> for more info.

  ## Examples

      (in Basecamp chat): !itbot say tech things
      "focus the laser on the platform interface"
  """

  @behaviour HiveMonitor.Handler

  @doc false
  @impl true
  def application_name, do: HiveMonitor.application_name()

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    with %{
           "callback_url" => callback_url,
           "command" => command,
           "creator" => %{"name" => creator}
         } <- HiveAtom.data_map(atom),
         response <- chatbot_response(creator, command) do
      HiveService.put_receipt(atom.id, application_name())

      headers = [
        {"User-Agent", "HIVE Monitor"},
        {"Content-Type", "application/json"}
      ]

      body = ~s({"content":"#{response}"})

      %{status_code: status_code} = HTTPoison.post!(callback_url, body, headers)
      Enum.member?(200..299, status_code)
    else
      _ -> false
    end
  end

  @spec chatbot_response(String.t(), String.t()) :: String.t()
  def chatbot_response(creator, command) when is_binary(creator) and is_binary(command) do
    actions = [
      {~r/say.tech.things/i, &Faker.Company.catch_phrase/0}
    ]

    default_response = "That's nice #{creator} 👍"

    Enum.reduce(actions, default_response, fn {regex, response_fn}, acc ->
      if command =~ regex do
        response_fn.()
      else
        acc
      end
    end)
  end
end
