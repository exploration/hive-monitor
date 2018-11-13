defmodule HiveMonitor.GeneHandler do
  @moduledoc """
  Forward an atom to the Gene app's incoming_atom endpoint.
  """

  alias HiveMonitor.Handler
  @behaviour Handler

  @token "3a9555043bea1ff8892914b8deceb0fd523243d0b"
  @url "https://explo-gene.herokuapp.com/hive/incoming_atoms"

  @doc false
  @impl true
  def application_name, do: "gene_production"

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
