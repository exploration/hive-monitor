defmodule HiveMonitor.BasecampChatHandler do
  @moduledoc """
  Basecamp "bot" for chats.

  Infers "commands" from the given chatbot text, and sends responses via Basecamp's API.

  Read <https://github.com/basecamp/bc3-api/blob/master/sections/chatbots.md> for more info.

  ## Examples

      (in Basecamp chat): !itbot say tech things
      "focus the laser on the platform interface"

  ## Notes
  
  Per Basecamp's docs:

  > In addition to the tags permitted for all rich text, the following tags are permitted for chatbot lines: `table`, `tr`, `td`, `th`, `thead`, `tbody`, `details`, and `summary`.
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
      {~r/say.tech.things/i, &Faker.Company.catch_phrase/0},
      {~r/help.me/i, fn -> sycophant(creator) end},
      {~r/what.do.you.think/i, fn -> sycophant(creator) end}
    ]

    default_response = """
    That's nice, #{creator} 👍. 
    <br>
    Type <strong>/help</strong> or <strong>/commands</strong> to see what I can do.
    """

    Enum.reduce(actions, default_response, fn {regex, response_fn}, acc ->
      cond do
        command =~ regex -> response_fn.()
        command =~ ~r/^.(help|command)/i -> help_text(actions)
        true -> acc
      end
    end)
  end

  defp help_text(actions) do
    action_list =
      Enum.map(actions, fn {regex, _} ->
        "<li>#{inspect(regex)}</li>"
      end)

    """
    Here's what I'm listening for:
    <br><br>
    <ul>#{action_list}</ul>
    """
  end

  defp sycophant(creator) do
    Enum.random([
      "I totally agree with #{creator}.",
      "#{creator} is absolutely right.",
      "I think #{creator} is spot-on.",
      "That's such a good idea, #{creator}!"
    ])
  end
end
