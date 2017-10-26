defmodule HiveMonitor.Router do

  @moduledoc """
  The HiveMonitor Router is a service designed to map incoming HIVE atoms to
  handler modules. It keeps a state of the atom "triplets", which identify the
  system from which the atom came, and which modules correspond to those
  triplets.

  The state can be configured on-the-fly through the `add_handler`,
  `remove_handler`, and `known_triplets` calls, or it can be set in the
  `:hive_monitor, :known_triplets` configuration variable.
  """

  use GenServer

  require Logger

  alias Explo.HiveAtom
  alias HiveMonitor.GenericHandler


  #----------------#
  # Client Methods #
  #----------------#
  
  @doc """
  Start this Router. Typically called by a Supervisor function.
  """
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
  Returns all known triplets, along with the list of any handlers associated with each triplet, as a map.

  The output of this function can be copy/pasted into the config variable
  `:hive_monitor, :known_triplets`, which is handy for when you've made
  configuration changes on-the-fly but want to store them in the
  configuration file for when you eventually restart.
  """
  def known_triplets() do
    GenServer.call(__MODULE__, {:known_triplets})
  end

  @doc """
  Stop handling the given triplet with the given handler.

  Example:

      HiveMonitor.Router.remove_handler({"portico","user","update"}, HiveMonitor.GenericHandler)
  """
  def remove_handler(triplet, handler) do
    GenServer.call(__MODULE__, {:remove_handler, triplet, handler})
  end


  @doc """
  Checks atom triplet against a known map of handlers (`@known_triplets`).
  Passes the atom to the `handle_atom` method of the relevant handler(s) if the
  triplet matches.

  This path is usually triggered automatically from the SocketClient.
  """
  def route(atom) when is_map(atom) do
    GenServer.cast(__MODULE__, {:route, atom})
  end


  #----------------#
  # Server Methods #
  #----------------#

  @doc """
  The state that this server contains is "known triplets" from HIVE
  """
  def init(:ok) do
    known_triplets = Application.get_env(:hive_monitor, :known_triplets) || %{}

    {:ok, known_triplets}
  end

  @doc false
  def handle_call({:add_handler, triplet, handler}, _from, known_triplets) do
    new_state = Map.update(known_triplets, triplet, [handler], fn handler_list ->
      case Enum.find(handler_list, fn v -> v == handler end) do
        nil -> [handler | handler_list]
        _ -> handler_list
      end
    end)

    {:reply, new_state, new_state}
  end
  
  @doc false
  def handle_call({:known_triplets}, _from, known_triplets) do
    {:reply, known_triplets, known_triplets}
  end

  @doc false
  def handle_call({:remove_handler, triplet, handler}, _from, known_triplets) do
    new_state = Map.update(known_triplets, triplet, [], fn handler_list ->
      List.delete handler_list, handler
    end)

    new_state = 
      case Map.fetch(new_state, triplet) do
        {:ok, []} -> Map.delete(new_state, triplet)
        _ -> new_state
      end

    {:reply, new_state, new_state}
  end

  @doc false
  def handle_cast({:route, atom_map}, known_triplets) do
    atom = HiveAtom.from_map(atom_map) 
    triplet = HiveAtom.triplet(atom)

    task_list = 
      case Map.fetch(known_triplets, triplet) do
        {:ok, module_list} ->
          Enum.map(module_list, fn module ->
            Logger.info(fn ->
                "ATOM received (#{atom.application}" <>
                ",#{atom.context},#{atom.process})" <>
                ", routing to #{to_string module}"
            end)
            Task.async(module, :handle_atom, [atom])
          end)
        :error -> 
          [Task.async(GenericHandler, :handle_atom, [atom])]
      end

    Enum.each(task_list, fn pid -> Task.await(pid) end)

    {:noreply, known_triplets}
  end
  
end
