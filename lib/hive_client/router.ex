defmodule HiveClient.Router do
  alias HiveClient.FMHandler
  alias HiveClient.GenericHandler
  alias HiveClient.PortalHandler

  @known_triplets %{
    {"portico", "user", "update"} => FMHandler,
    {"portal", "course_form", "update"} => PortalHandler
  }

  @doc """
    Checks atom triplet against a known map of handlers. 
    Passes the atom to the `handle_atom` method of the relevant handler if the
    triplet matches.
  """
  def route(atom) when is_map(atom) do
    triplet = {atom["application"], atom["context"], atom["process"]}
    case Map.fetch(@known_triplets, triplet) do
      {:ok, module} ->
        apply(module, :handle_atom, [atom])
      :error -> 
        apply(GenericHandler, :handle_atom, [atom])
    end
  end
end
