defmodule HiveMonitor.FacappHandler do
  @moduledoc """
  Forward an atom to the Faculty Application app's incoming_atom endpoint.
  """

  alias HiveMonitor.Handler
  @behaviour Handler

  @token "70a81416c9a83910a0d0b8af4897e43ba330ef757d566285"
  @url "http://facapp.lab.explo.org/hive/incoming_atoms"

  @doc false
  @impl true
  def application_name, do: "facapp2_production"

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    atom_encoded = Handler.atom_to_uri_form(atom)

    body = "atom=#{atom_encoded}&token=#{@token}"

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
