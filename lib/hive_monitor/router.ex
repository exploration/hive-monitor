defmodule HiveMonitor.Router do
  @moduledoc """
  The HiveMonitor Router is a service designed to map incoming HIVE atoms to
  handler modules. It keeps a state of the atom "triplets", which identify the
  system from which the atom came, and which modules correspond to those
  triplets.

  The state can be configured on-the-fly through the `add_handler`,
  `remove_handler`, and `get_config` calls, or it can be set in the
  `:hive_monitor, :router_config` configuration variable.
  """

  use GenServer

  require Logger

  alias HiveMonitor.GenericHandler

  @typedoc "Just a unique list of module names."
  @type module_list :: [module()]

  @typedoc """
  A `config` in the context of a `HiveMonitor.Router` is a HIVE triplet, mapped
  to a list of modules that implement the `Handler` behavior, which can
  receive a HIVE atom when one is routed in. 
  """
  @type config :: %{HiveAtom.triplet() => module_list}

  # ----------------#
  # Client Methods #
  # ----------------#

  @doc """
  Start this Router. Typically called by a Supervisor function.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Add a new handler to the HIVEMonitor system on-the-fly.

  Returns the current `Router` config.

  ## Example:

      iex> HiveMonitor.Router.add_handler({"portico","user","update"}, HiveMonitor.GenericHandler)
      %{{"explo", "notification", "create"} => [HiveMonitor.NotificationHandler],
        {"portico", "user", "update"} => [HiveMonitor.GenericHandler]}
        i
  """
  @spec add_handler(HiveAtom.triplet(), module()) :: config()
  def add_handler(triplet, handler) do
    GenServer.call(__MODULE__, {:add_handler, triplet, handler})
  end

  @doc """
  Returns all known triplets, along with the list of any handlers associated
  with each triplet, as a `Router.config()` type.

  The output of this function can be copy/pasted into the config variable
  `:hive_monitor, :router_config`, which is handy for when you've made
  configuration changes on-the-fly but want to store them in the configuration
  file for when you eventually restart.
  """
  @spec get_config() :: config()
  def get_config do
    GenServer.call(__MODULE__, {:get_config})
  end

  @doc """
  Stop handling the given triplet with the given handler. If the given triplet
  no longer has any handlers associated with it, the triplet will be removed
  entirely from the config.

  Returns the current `Router` config.

  ## Example:

      iex> HiveMonitor.Router.remove_handler( \
          {"portico","user","update"}, HiveMonitor.GenericHandler)
      %{{"portico","user","update"} => [SomeOtherHandler]}
      iex> HiveMonitor.Router.remove_handler( \
          {"portico","user","update"}, SomeOtherHandler)
      %{}
  """
  @spec remove_handler(HiveAtom.triplet(), module()) :: config()
  def remove_handler(triplet, handler) do
    GenServer.call(__MODULE__, {:remove_handler, triplet, handler})
  end

  @doc """
  Checks atom triplet against the known map of handlers.  Passes the atom to
  the `handle_atom` method of the relevant handler(s) if the triplet matches.

  This path is usually triggered automatically from the SocketClient.
  """
  @spec route(map()) :: :ok
  def route(atom) when is_map(atom) do
    GenServer.cast(__MODULE__, {:route, atom})
  end

  @doc """
  This is a synchronous version of route, which is handy for testing because it
  returns the results of each handle_atom() method called by a Handler.
  """
  @spec route(map(), :await) :: {:ok, :success} | :error
  def route(atom, :await) when is_map(atom) do
    GenServer.call(__MODULE__, {:route, atom})
  end

  # ----------------#
  # Server Methods #
  # ----------------#

  @doc false
  def init(args) do
    config = Application.get_env(:hive_monitor, :router_config) || %{}

    config =
      case Keyword.fetch(args, :config) do
        {:ok, triplets} when is_map(triplets) -> triplets |> Map.merge(config)
        :error -> config
      end

    known_triplets = config_to_known_triplets(config)

    {:ok, known_triplets}
  end

  @doc false
  def handle_call({:add_handler, triplet, handler}, _from, known_triplets) do
    new_state =
      Map.update(
        known_triplets,
        triplet,
        MapSet.new([handler]),
        &MapSet.put(&1, handler)
      )

    config = known_triplets_to_config(new_state)

    {:reply, config, new_state}
  end

  @doc false
  def handle_call({:get_config}, _from, known_triplets) do
    config = known_triplets_to_config(known_triplets)
    {:reply, config, known_triplets}
  end

  @doc false
  def handle_call({:remove_handler, triplet, handler}, _from, known_triplets) do
    minus_handler =
      Map.update(
        known_triplets,
        triplet,
        MapSet.new(),
        &MapSet.delete(&1, handler)
      )

    empty_set = MapSet.new()

    new_state =
      case Map.fetch(minus_handler, triplet) do
        {:ok, ^empty_set} -> Map.delete(minus_handler, triplet)
        _ -> minus_handler
      end

    config = known_triplets_to_config(new_state)

    {:reply, config, new_state}
  end

  @doc false
  def handle_call({:route, atom_map}, _from, known_triplets) do
    result = routep(atom_map, known_triplets)
    {:reply, result, known_triplets}
  end

  @doc false
  def handle_cast({:route, atom_map}, known_triplets) do
    routep(atom_map, known_triplets)
    {:noreply, known_triplets}
  end

  ### PRIVATE ZONE ###

  # Converts a `Router.config` type into the internal representation that we
  # use in our Router state.
  defp config_to_known_triplets(config) do
    Map.new(config, fn {triplet, module_list} ->
      {triplet, MapSet.new(module_list)}
    end)
  end

  # Convert from internal Router state to a `Router.config` type.
  defp known_triplets_to_config(known_triplets) do
    Map.new(known_triplets, fn {triplet, module_set} ->
      {triplet, MapSet.to_list(module_set)}
    end)
  end

  defp log_and_send(module, atom) do
    Logger.info(fn ->
      "ATOM #{atom.id} received (#{atom.application}" <>
        ",#{atom.context},#{atom.process}), routing to #{to_string(module)}"
    end)

    Task.async(module, :handle_atom, [atom])
  end

  # Attempt to asynchronously route the atom to all known handlers. If no known handlers exist, route to the GenericHandler.
  defp routep(atom_map, known_triplets) do
    atom = HiveAtom.from_map(atom_map)
    triplet = HiveAtom.triplet(atom)

    task_list =
      case Map.fetch(known_triplets, triplet) do
        {:ok, module_list} ->
          Enum.map(module_list, &log_and_send(&1, atom))

        :error ->
          [Task.async(GenericHandler, :handle_atom, [atom])]
      end

    Enum.map(task_list, fn t -> Task.await(t, :timer.seconds(60)) end)
  end
end
