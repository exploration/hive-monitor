defmodule HiveMonitor.Handlers.GenericHandler do
  @moduledoc """
  The generic case is merely to log the atom

  You can stop this logging in `config.exs`:

      config :hive_monitor,
        log_unrecognized_atoms: false
  """

  @behaviour HiveMonitor.Handler

  require Logger

  @doc false
  @impl true
  def application_name, do: :none

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    if Application.get_env(:hive_monitor, :log_unrecognized_atoms, false) do
      message =
        "Generic Handler got the atom: (#{atom.application}" <>
          ", #{atom.context}, #{atom.process}) data: #{inspect(atom.data)}"

      Logger.info(fn -> message end)
    end

    {:ok, :success}
  end
end
