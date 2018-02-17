defmodule HiveMonitor.PorticoBuffer do
  @moduledoc """
  The PorticoBuffer exists because Portico is no good at handling a lot of information all at once. Specifically, it's really bad at handling multiple simultaneous script invocations. Since HIVE Atoms come through HIVE Monitor in realtime, we build this "buffer" as a way of squirting them over to Portico at a rate that Portico can handle. 
  """

  use GenServer

  require Logger

  alias HiveMonitor.Handler

  @behaviour Handler

  @script_name "pub - receive new atom from HIVE (atom_json)"
  @server_url "fmp://minerva.explo.org/hive_data"

  defmodule State do
    @moduledoc false

    defstruct rate: :timer.seconds(15), atoms: []

    @typedoc """
    The state of the PorticoBuffer has a rate (at which Portico receives atoms), and a list of atoms remaining to parse.
    """
    @type t :: %__MODULE__{
            rate: integer(),
            atoms: [HiveAtom.t()]
          }
  end

  # ----------------#
  # Client Methods #
  # ----------------#

  @doc """
  Starts the PorticoBuffer running. You don't typically need to do this by hand.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :cool, name: __MODULE__)
  end

  @doc """
  Add an atom to the Portico queue
  """
  @spec add_atom(HiveAtom.t()) :: State.t()
  def add_atom(%HiveAtom{} = atom) do
    GenServer.call(__MODULE__, {:add_atom, atom})
  end

  @doc """
  Returns the current state
  """
  @spec get_config() :: State.t()
  def get_config() do
    GenServer.call(__MODULE__, :get_config)
  end

  @doc """
  Give it a HiveAtom, and it'll send it to Portico.
  """
  @spec send_atom_to_portico(HiveAtom.t()) :: {:ok, atom()}
  def send_atom_to_portico(%HiveAtom{} = atom) do
    url = "#{@server_url}?script=#{URI.encode(@script_name)}" <>
      "&param=#{atom_to_fm_query(atom)}"

    Logger.info(fn -> "Sending atom #{atom.id} to Portico..." end)

    System.cmd("/usr/bin/open", [url])

    {:ok, :fine}
  end

  @doc """
  Update the timer by which we send atoms in the buffer to Portico
  """
  @spec update_rate(integer()) :: {:error, atom()} | {:ok, State.t()}
  def update_rate(rate) do
    GenServer.call(__MODULE__, {:update_rate, rate})
  end

  # -----------------#
  # Handler Methods #
  # -----------------#

  @doc false
  @impl true
  def application_name(), do: "portico"

  @doc """
  Add a new atom to the buffer. One will get sent to Portico every `rate` milliseconds.
  """
  @impl true
  @spec handle_atom(HiveAtom.t()) :: {:ok, atom()}
  def handle_atom(%HiveAtom{} = atom) do
    add_atom(atom)
    {:ok, :fine}
  end

  # ----------------#
  # Server Methods #
  # ----------------#

  @doc false
  @impl true
  def init(_args) do
    state = %State{}

    Logger.info(fn ->
      "Starting PorticoBuffer at a rate of " <>
        "#{inspect(Float.round(state.rate / 1000))} seconds..."
    end)

    send_next_dequeue_message(state)
    {:ok, state}
  end

  @doc false
  @impl true
  def handle_call({:add_atom, atom}, _from, state) do
    new_state = update_in(state.atoms, fn atoms -> [atom | atoms] end)
    {:reply, new_state, new_state}
  end

  @doc false
  @impl true
  def handle_call(:get_config, _from, state) do
    {:reply, state, state}
  end

  @doc false
  @impl true
  def handle_call({:update_rate, rate}, _from, state) do
    new_state = %{state | rate: rate}
    {:reply, new_state, new_state}
  end

  @doc false
  @impl true
  def handle_info(:dequeue, state) do
    {atom, remaining_atoms} = List.pop_at(state.atoms, -1)
    new_state = %{state | atoms: remaining_atoms}

    case atom do
      nil -> nil
      _ -> send_atom_to_portico(atom)
    end

    send_next_dequeue_message(state)
    {:noreply, new_state}
  end

  @doc false
  @impl true
  def handle_info(message, state) do
    Logger.info(fn -> "PorticoBuffer received a message: #{inspect(message)}." end)
    {:noreply, state}
  end

  # ----------------#
  # Helper Methods #
  # ----------------#

  defp send_next_dequeue_message(state) do
    Process.send_after(__MODULE__, :dequeue, state.rate)
  end

  # FileMaker can't handle "+"es in passed queries, but otherwise handles them
  # like form data...
  defp atom_to_fm_query(%HiveAtom{} = atom) do
    atom
    |> Handler.atom_to_uri_form()
    |> String.replace("+", "%20")
  end
end
