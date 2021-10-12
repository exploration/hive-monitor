defmodule HiveMonitor.Handlers.GeneHandler do
  @moduledoc """
  Forward an atom to the Gene app's incoming_atom endpoint.

  Atoms can be forwarded to both staging (de-activated by default) +
  production (activated by default) servers, behind the following
  configuration:

      config :hive_monitor, HiveMonitor.Handlers.GeneHandler,
        send_to_production: true,
        send_to_staging: true
  """

  alias HiveMonitor.Handler
  @behaviour Handler

  @production_url "https://portal.explo.org/hive/incoming_atoms"
  @staging_url "https://gene.test.explo.org/hive/incoming_atoms"

  @doc false
  @impl true
  def application_name, do: "gene_production"

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    atom_encoded = Handler.atom_to_uri_form(atom)

    body = "atom=#{atom_encoded}&token=#{Application.get_env(:hive_monitor, :token_gene)}"

    headers = [
      {"User-Agent", "HIVE Monitor"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    if get_config(:send_to_staging) do
      HTTPoison.post!(@staging_url, body, headers)
    end

    if get_config(:send_to_production, true) do
      %{status_code: status_code} = HTTPoison.post!(@production_url, body, headers)

      case Enum.member?(200..299, status_code) do
        true -> {:ok, :success}
        false -> :error
      end
    end
  end

  defp get_config(key, default \\ nil) do
    Application.get_env(:hive_monitor, __MODULE__)
    |> Keyword.get(key, default)
  end
end
