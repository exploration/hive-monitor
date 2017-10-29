defmodule HiveMonitor.CronServer do

  @moduledoc """
  The CronServer is an attempt to consolidate all HIVE-related chores into this
  one HiveMonitor zone. Typically in a HIVE system, you'll have certain chores
  like shell scripts, remote triggers, etc. that need to be run on a periodic
  timer (because not everything can be fully realtime eg. in FileMaker
  systems). 
  
  The idea is that you make shell scripts or other system scripts to run the
  periodic maintenance tasks, and then you can run them periodically using this
  CronServer.  
  """

  use GenServer
  require Logger

  defmodule Cron do
    @enforce_keys [:name]
    defstruct [
      :name, :ref,
      module: System,
      fun: :cmd,
      args: ["/bin/echo", "hello world"],
      rate: :timer.minutes(60)
    ]
  end


  #----------------#
  # Client Methods #
  #----------------#
  
  @doc """
  Starts the CronServer running. You don't typically need to do this by hand.
  You can't pass methods to this server, instead use the :hive_monitor :crons
  config variable to send them in.
  """
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Add a new Cron. Send it a %Cron{} struct with a unique name, and it'll be
  happy.

  Returns the Cron, with an updated timer reference, on success.
  Returns {:error, "description"} otherwise.
  """
  def add_cron(cron) do
    GenServer.call(__MODULE__, {:add_cron, cron})
  end

  @doc """
  Delete a Cron (by name) from the list of running Crons (and cancel its
  timer).

  Returns the list of running Crons, on success or failure. If it was
  successful, the named Cron will be missing from the returned state :)
  """
  def delete_cron(name) do
    GenServer.call(__MODULE__, {:delete_cron, name})
  end

  @doc """
  Update a Cron's timer (by name and rate in ms).

  Returns the updated Cron struct on success, and {:error, "description"}
  otherwise.

  Pro tip: Use :timer.seconds() / :timer.minutes() etc. as a convenience
  method so you don't have to do manual millisecond math.
  """
  def update_rate(name, rate) do
    GenServer.call(__MODULE__, {:update_rate, name, rate})
  end

  @doc """
  Returns a list of all Cron (structs) currently running.
  """
  def list_crons() do
    GenServer.call(__MODULE__, :list_crons)
  end

  @doc """
  Returns a list of all Crons currently running as a map. This is handy for
  copy/pasting into the `:hive_monitor, :crons` config variable for when you've
  made changes to the server on-the-fly and want to store them.
  """
  def get_config() do
    crons = GenServer.call(__MODULE__, :list_crons)
    Enum.map(crons, fn(cron) ->
      %{
        name: cron.name,
        module: cron.module,
        fun: cron.fun,
        args: cron.args,
        rate: cron.rate
      }
    end)
  end

  @doc """
  Given a %Cron{}, run its Module/Function/Args.
  """
  def execute_cron(cron) do
    Logger.info("CronServer run: #{cron.name} (every #{cron.rate / 1000}s): " <>
        "#{inspect cron.module} #{inspect cron.fun} #{inspect cron.args}")
    apply(cron.module, cron.fun, cron.args)
  end



  #----------------#
  # Server Methods #
  #----------------#

  def init(:ok) do
    # Make sure that we run terminate() on exit.
    Process.flag(:trap_exit, true)

    # We can't pass %Cron{}s from the config, so we have to use maps, and then
    # convert them to %Cron{}s here.
    cron_maps = Application.get_env(:hive_monitor, :crons) || []
    cronit = fn(map) -> struct(Cron, map) end
    crons = cron_maps |> Enum.map(cronit)

    state = Enum.map(crons, fn(cron) -> delay_then_init(cron) end)
    {:ok, state}
  end


  def handle_call({:add_cron, cron}, _from, state) do
    case find_name(state, cron.name) do
      :no_match ->
        updated_cron = set_timer(cron)
        new_state = [ updated_cron | state ]
        {:reply, updated_cron, new_state}
      _ -> {:reply, {:error, "duplicate key"}, state}
    end
  end

  def handle_call({:delete_cron, name}, _from, state) do
    new_state = case find_name_index(state, name) do
      :no_match -> state
      index -> 
        cancel_timer(Enum.at(state, index))
        List.delete_at(state, index)
    end

    {:reply, new_state, new_state}
  end

  def handle_call(:list_crons, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update_rate, name, rate}, _from, state) do
    case find_name(state, name) do
      :no_match -> 
        {:reply, {:error, "no key found"}, state}
      cron ->
        case cancel_timer(cron) do
          {:ok, :cancel} -> 
            new_cron = set_timer(%{cron | rate: rate})
            new_state = replace_cron(state, cron, new_cron)
            {:reply, new_cron, new_state}
          _ -> {:reply, {:error, "timer cancellation error"}, state}
        end
    end
  end

  def handle_info({:set_timer, cron}, state) do
    set_timer(cron)
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.info(fn -> "Quitting CronServer because: #{inspect reason}." end)
    Enum.each(state, fn(cron) ->
      cancel_timer(cron)
    end)
    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.info(fn -> "CronServer received a message: #{inspect message}." end)
    {:noreply, state}
  end




  # Cancel the Erlang timer for the given Cron (if there is a proper timer
  # reference)
  # See http://erlang.org/doc/man/timer.html for details
  defp cancel_timer(cron) do
    case cron.ref do
      nil -> {:error, "no timer reference found"}
      ref -> 
        Logger.info(fn -> "Cancelling timer for #{cron.name}" end)
        :timer.cancel(ref_to_tref(ref))
    end
  end

  # If we don't slightly delay timer initialization, we'll get a situation
  # where every single %Cron{} will start at the exact same time, and then get
  # re-started at the exact same time when they overlap.
  #
  # For example, if you have a Cron every 15 seconds, and another every 30,
  # then every 30 seconds both of your Crons will fire. This can cause problems
  # with loading systems, so it's better to stagger the starting of those
  # Crons.
  #
  # The default "spread" of this timer is 5 minutes, but it can be configured
  # with the :hive_monitor, :cron_init_spread configuration variable.
  defp delay_then_init(cron) do
    spread = 
      Application.get_env(:hive_monitor, :cron_init_spread) ||
      :timer.minutes(5)
    start_time = :rand.uniform(spread) 

    Logger.info(fn -> 
      "Starting #{inspect cron.name}'s timer in " <>
      "#{inspect(start_time / 1000 |> Float.round())} seconds."
    end)

    Process.send_after(__MODULE__, {:set_timer, cron}, start_time)
  end

  # Erlang timer functions return TRefs. This function will convert the timer
  # reference into the proper format to be compatible with Erlang's Timer
  # library.
  # See http://erlang.org/doc/man/timer.html for details
  defp ref_to_tref(reference) do
    {:interval, reference}
  end

  # Search the state for a Cron matching the given name
  defp find_name(state, name) do
    Enum.find(state, :no_match, fn(cron) -> cron.name == name end)
  end

  # Same as find_name, but return the index of the matching Cron
  defp find_name_index(state, name) do
    case Enum.find_index(state, fn(cron) -> cron.name == name end) do
      nil -> :no_match
      index -> index
    end
  end

  defp replace_cron(state, old_cron, new_cron) do
    case find_name_index(state, old_cron.name) do
      :no_match -> state
      index -> List.replace_at(state, index, new_cron)
    end
  end

  #Activate the timer for the given Cron using the Erlang :timer library.
  #Only activates the timer if there is no current timer reference.
  #See http://erlang.org/doc/man/timer.html for details
  defp set_timer(cron) do
    case cron.ref do
      nil -> 
        Logger.info(fn -> "CronServer activating #{cron.name}" <>
            " every #{cron.rate / 1000}s" end )
        {:ok, {:interval, ref}} = 
            :timer.apply_interval(cron.rate, __MODULE__, :execute_cron, [cron])
        %{cron | ref: ref}
      _ -> cron
    end
  end
end
