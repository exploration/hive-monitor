defmodule HiveMonitor.Handlers.Void do
  @moduledoc """
  Send an atom into the void.

  You use this if you know that atoms are gonna come through but you
  don't necessarily want to log them all.
  """

  @behaviour HiveMonitor.Handler

  @doc false
  @impl true
  def application_name, do: :none

  @doc false
  @impl true
  def handle_atom(%HiveAtom{} = _atom) do
    {:ok, :success}
  end
end
