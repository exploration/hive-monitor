defmodule HiveMonitor.StagnantAtomChecker do
  @moduledoc """
  The Stagnant Atom Checker exists because sometimes systems that receive HIVE atoms fail to parse them properly + mark them as "received". This means that subsequent calls `Handler.handle_missed_atoms()` will end up returning the same set of... stagnant... atoms. So we want to be able to tell that this is happening + get a warning about it!
  """

  use GenServer

  alias ExploComm.HipChat

  @typedoc """
  A `StagnantAtomChecker` holds two sets of Atoms: the previous run, and the current run, of `Handler.handle_missed_atom()`.
  """
  @type state :: %{current: MapSet.t(), previous: MapSet.t()}

  # ----------------#
  # Client Methods #
  # ----------------#

  @doc "Start the server running. Not typically done manually."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Add an atom to the "current" list of atoms. If it's already in the list, it'll be ignored.
  """
  @spec add_atom_list([HiveAtom.t()]) :: state()
  def add_atom_list(atom_list) do
    GenServer.call(__MODULE__, {:add_atom_list, atom_list})
  end

  @doc """
  Returns a list of atoms that remained in the list between the last "run" and the current "run".
  """
  @spec get_stagnant_atoms() :: state()
  def get_stagnant_atoms do
    GenServer.call(__MODULE__, :get_stagnant_atoms)
  end

  @doc """
  Just returns the the current state() data.
  """
  @spec get_state() :: state()
  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc """
  Notify an admin if things are stagnant
  """
  @spec notify_if_stagnant() :: :ok
  def notify_if_stagnant do
    GenServer.cast(__MODULE__, :notify_if_stagnant)
  end

  @doc """
  Copy the current run to the previous run, and reset the current run.
  """
  @spec reset_current() :: state()
  def reset_current do
    GenServer.call(__MODULE__, :reset_current)
  end

  # ----------------#
  # Server Methods #
  # ----------------#

  @doc false
  def init(_args) do
    state = %{previous: MapSet.new(), current: MapSet.new()}

    {:ok, state}
  end

  @doc false
  def handle_call({:add_atom_list, atom_list}, _from, state) do
    atom_mapset = MapSet.new(atom_list)
    updated_current = MapSet.union(state.current, atom_mapset)
    new_state = %{state | current: updated_current}

    {:reply, {:ok, new_state}, new_state}
  end

  @doc false
  def handle_call(:get_stagnant_atoms, _from, state) do
    stagnant_atoms =
      state.current
      |> MapSet.intersection(state.previous)
      |> MapSet.to_list()

    {:reply, {:ok, stagnant_atoms}, state}
  end

  @doc false
  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  @doc false
  def handle_call(:reset_current, _from, state) do
    new_state = %{state | previous: state.current, current: MapSet.new()}

    {:reply, {:ok, new_state}, new_state}
  end

  @doc false
  def handle_cast(:notify_if_stagnant, state) do
    stagnant_atom_ids = Enum.map(get_stagnant_atoms(), fn atom -> atom.id end)

    case Enum.count(stagnant_atom_ids) do
      0 ->
        false

      _ ->
        HipChat.send_notification(
          "WARNING: Stagnant atoms detected: #{inspect(stagnant_atom_ids)}",
          from: "HIVE Monitor",
          room: 143_945
        )
    end

    {:noreply, state}
  end
end
