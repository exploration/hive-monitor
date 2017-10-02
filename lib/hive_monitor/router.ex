defmodule HiveMonitor.Router do
  alias HiveMonitor.GenericHandler
  require Logger

  use GenServer

  #----------------#
  # Client Methods #
  #----------------#
  
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
    Add a new handler to the HIVEMonitor system on-the-fly

    Example:

        HiveMonitor.Router.add_handler({"portico","user","update"}, HiveMonitor.GenericHandler)
  """
  def add_handler(triplet, handler) do
    GenServer.call(__MODULE__, {:add_handler, triplet, handler})
  end

  @doc """
    Stop handling the given triplet with the given handler on-the-fly

    Example:

        HiveMonitor.Router.remove_handler({"portico","user","update"}, HiveMonitor.GenericHandler)
  """
  def remove_handler(triplet, handler) do
    GenServer.call(__MODULE__, {:remove_handler, triplet, handler})
  end


  @doc """
    Checks atom triplet against a known map of handlers (`@known_triplets`).
    Passes the atom to the `handle_atom` method of the relevant handler if the
    triplet matches.

    This path is usually triggered automatically from the SocketClient
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


  def handle_call({:add_handler, triplet, handler}, _from, known_triplets) do
    new_state = Map.update(known_triplets, triplet, [handler], fn(handler_list) ->
      case Enum.find(handler_list, fn(v) -> v == handler end) do
        nil -> [handler | handler_list]
        _ -> handler_list
      end
    end)

    {:reply, new_state, new_state}
  end

  def handle_call({:remove_handler, triplet, handler}, _from, known_triplets) do
    new_state = Map.update(known_triplets, triplet, [], fn(handler_list) ->
      List.delete handler_list, handler
    end)

    {:reply, new_state, new_state}
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
