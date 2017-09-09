defmodule HiveClient.Router do
  alias HiveClient.FMHandler
  alias HiveClient.GenericHandler
  alias HiveClient.PortalHandler
  require Logger

  # Put yer triplets here as you add new systems
  @known_triplets %{
    {"portico", "user", "update"} => PortalHandler,
    {"portal_production", "course", "update"} => FMHandler
  }

  @doc """
    Checks atom triplet against a known map of handlers (`@known_triplets`). 
    Passes the atom to the `handle_atom` method of the relevant handler if the
    triplet matches.
  """
  def route(atom) when is_map(atom) do
    Logger.info("ATOM received: #{inspect atom}")

    triplet = {atom["application"], atom["context"], atom["process"]}

    case Map.fetch(@known_triplets, triplet) do
      {:ok, module} ->
        apply(module, :handle_atom, [atom])
      :error -> 
        apply(GenericHandler, :handle_atom, [atom])
    end
  end
end
