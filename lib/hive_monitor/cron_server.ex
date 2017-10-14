defmodule HiveMonitor.CronServer do
  use GenServer
  require Logger

  defmodule Cron do
    @enforce_keys [:name, :cmd, :args, :rate]
    defstruct name: nil,
        cmd: "/bin/echo",
        args: ["hello world"],
        rate: :timer.seconds(10),
        ref: nil
  end

  #----------------#
  # Client Methods #
  #----------------#
  
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_cron(cron) do
    GenServer.call(__MODULE__, {:add_cron, cron})
  end

  def delete_cron(name) do
    GenServer.call(__MODULE__, {:delete_cron, name})
  end

  def update_rate(name, rate) do
    GenServer.call(__MODULE__, {:update_rate, name, rate})
  end

  def list_crons() do
    GenServer.call(__MODULE__, :list_crons)
  end



  #----------------#
  # Server Methods #
  #----------------#

  def init(:ok) do
    # We can't pass %Cron{}s from the config, so we have to use maps, and then
    # convert them to %Cron{}s here.
    cron_maps = Application.get_env(:hive_monitor, :crons) || []
    cronit = fn(map) -> struct(Cron, map) end
    crons = cron_maps |> Enum.map(cronit)

    state = Enum.map(crons, fn(cron) -> set_timer(cron) end)
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


  defp cancel_timer(cron) do
    case cron.ref do
      nil -> {:error, "no reference found"}
      ref -> :timer.cancel({:interval, ref})
    end
  end

  defp find_name(state, name) do
    Enum.find(state, :no_match, fn(cron) -> cron.name == name end)
  end

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

  defp set_timer(cron) do
    Logger.info "CronServer refresh #{cron.name} every #{cron.rate / 1000}s: #{cron.cmd} #{cron.args}"
    {:ok, {:interval, ref}} = :timer.apply_interval(
        cron.rate, System, :cmd, [cron.cmd, cron.args])
    %{cron | ref: ref}
  end
end
