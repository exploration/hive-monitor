defmodule HiveMonitor.Handlers.CoursesHandler do
  @moduledoc """
  Forward an atom to the Courses app's incoming_atom endpoint.
  """

  alias HiveMonitor.Handler
  @behaviour Handler

  @url "https://courses.explo.org/hive/incoming_atoms"

  @doc false
  @impl true
  def application_name, do: "courses"

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    atom_encoded = Handler.atom_to_uri_form(atom)

    body = "atom=#{atom_encoded}&token=#{Application.get_env(:hive_monitor, :token_courses)}"

    headers = [
      {"User-Agent", "HIVE Monitor"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    %{status_code: status_code} = HTTPoison.post!(@url, body, headers)

    case Enum.member?(200..299, status_code) do
      true -> {:ok, :success}
      false -> :error
    end
  end
end
