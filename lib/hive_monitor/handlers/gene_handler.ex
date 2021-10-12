defmodule HiveMonitor.Handlers.GeneHandler do
  @moduledoc """
  Forward an atom to the Gene app's incoming_atom endpoint.

  Atoms can be routed to staging instead of production, if the following
  configuration flag is set:

      config :hive_monitor, HiveMonitor.Handlers.GeneHandler,
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

    %{status_code: status_code} = cond do
      get_config(:send_to_staging) ->
        HTTPoison.post!(@staging_url, body, headers)
      get_config(:send_to_production, true) ->
       HTTPoison.post!(@production_url, body, headers)
    end

    case Enum.member?(200..299, status_code) do
      true -> {:ok, :success}
      false -> :error
    end
  end

  defp get_config(key, default \\ nil) do
    Application.get_env(:hive_monitor, __MODULE__)
    |> Keyword.get(key, default)
  end
end
