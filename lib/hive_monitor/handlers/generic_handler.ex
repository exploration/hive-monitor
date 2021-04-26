defmodule HiveMonitor.Handlers.GenericHandler do
  @moduledoc """
  The generic case is merely to log the atom

  You can stop this logging in `config.exs`:

      config :hive_monitor,
        log_unrecognized_atoms: false

  You can stop generic logging for an individual triplet (atom
  identifier) by adding this to your config:

      config :hive_monitor,
        ignore_these_triplets: [
          {"some", "app", "triplet"},
          ...
        ]
  """

  @behaviour HiveMonitor.Handler

  require Logger

  @doc false
  @impl true
  def application_name, do: :none

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = atom) do
    if we_are_logging_this(atom) do
      message =
        "Generic Handler got the atom: (#{atom.application}" <>
          ", #{atom.context}, #{atom.process}) data: #{inspect(atom.data)}"

      Logger.info(fn -> message end)
    end

    {:ok, :success}
  end

  defp log_unrecognized_atoms do
    Application.get_env(:hive_monitor, :log_unrecognized_atoms, false)
  end

  defp triplets_of_ignoreville do
    Application.get_env(:hive_monitor, :ignore_these_triplets, [])
  end

  defp we_are_logging_this(atom) do
    log_unrecognized_atoms() and HiveAtom.triplet(atom) not in triplets_of_ignoreville()
  end
end
