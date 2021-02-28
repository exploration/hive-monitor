defmodule HiveMonitor.Handlers.KitchenHandler do
  @moduledoc """
  Forward an atom to the Kitchen Sync app's incoming_atom endpoint.
  """

  alias HiveMonitor.Handler
  @behaviour Handler

  @token "a24424edddde6ed1a54da081b89499469adf2011949397a6"
  @url "https://kitchen.explo.org/hive/incoming_atoms"

  @doc false
  @impl true
  def application_name, do: "kitchen_production"

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
