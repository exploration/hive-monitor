defmodule HiveMonitor.Router do
  alias HiveMonitor.GenericHandler
  require Logger

  @doc """
    Checks atom triplet against a known map of handlers (`@known_triplets`). 
    Passes the atom to the `handle_atom` method of the relevant handler if the
    triplet matches.
  """
  def route(atom) when is_map(atom) do
    triplet = {atom["application"], atom["context"], atom["process"]}
    known_triplets = Application.get_env(:hive_monitor, :known_triplets) || %{}

    case Map.fetch(known_triplets, triplet) do
      {:ok, module} ->
        Logger.info("ATOM received (#{atom["application"]},#{atom["context"]},#{atom["process"]}), routing to #{to_string module}")
        Task.start_link(module, :handle_atom, [atom])
      :error -> 
        Task.start_link(GenericHandler, :handle_atom, [atom])
    end
  end
end
