defmodule HiveMonitor.BasecampChatHandler do
  @moduledoc """
  Basecamp "bot" for chats.

  Infers "commands" from the given chatbot text, and sends responses via Basecamp's API.

  Read <https://github.com/basecamp/bc3-api/blob/master/sections/chatbots.md> for more info.

  ## Examples

      (in Basecamp chat): !itbot say_tech_things
      "focus the laser on the platform interface"
  """

  @behaviour HiveMonitor.Handler

  @doc false
  @impl true
  def application_name, do: HiveMonitor.application_name()

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    with {:ok, callback_url} <- callback_url(atom),
         response <- chatbot_response(atom) do
      HiveService.put_receipt(atom.id, application_name())
      %{status_code: status_code} = HTTPoison.post!(callback_url, [{"content", response}])
      Enum.member?(200..299, status_code) 
    else
      _ -> false
    end
  end

  @spec chatbot_response(HiveAtom.t) :: String.t
  def chatbot_response(%HiveAtom{} = atom) do
    command =
      atom
      |> HiveAtom.data_map()
      |> Map.get("command", "")

    case command do
      "say_tech_things" -> Faker.Company.catch_phrase()
      _ -> "command not understood"
    end
  end

  defp callback_url(atom) do
    atom
    |> HiveAtom.data_map()
    |> Map.fetch("callback_url")
  end
end
