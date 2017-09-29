defmodule HiveMonitor.Router do
  alias HiveMonitor.GenericHandler
  require Logger

  use GenServer

  #----------------#
  # Client Methods #
  #----------------#
  
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
    Checks atom triplet against a known map of handlers (`@known_triplets`).
    Passes the atom to the `handle_atom` method of the relevant handler if the
    triplet matches.
  """
  def route(atom) when is_map(atom) do
    GenServer.cast(__MODULE__, {:route, atom})
  end


  #----------------#
  # Server Methods #
  #----------------#

  # The state that this server contains is "known triplets" from HIVE
  def init(:ok) do
    known_triplets = Application.get_env(:hive_monitor, :known_triplets) || %{}

    {:ok, known_triplets}
  end

  def handle_cast({:route, atom}, known_triplets) do
    triplet = {atom["application"], atom["context"], atom["process"]}

    case Map.fetch(known_triplets, triplet) do
      {:ok, module_list} ->
        Enum.each(module_list, fn(module) ->
          Logger.info("ATOM received (#{atom["application"]},#{atom["context"]},#{atom["process"]}), routing to #{to_string module}")
          Task.start_link(module, :handle_atom, [atom])
        end)
      :error -> 
        Task.start_link(GenericHandler, :handle_atom, [atom])
    end

    {:noreply, known_triplets}
  end
end
