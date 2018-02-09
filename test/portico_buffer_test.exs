defmodule PorticoBufferTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.PorticoBuffer
  alias HiveMonitor.PorticoBuffer.State

  describe "Basic API" do
    test "Retrieving state" do
      {:ok, _} = start_supervised({PorticoBuffer, []})

      state = PorticoBuffer.get_config
      assert state.__struct__ == State
      assert Map.has_key? state, :atoms
      assert Map.has_key? state, :rate
    end

    test "Updating buffer rate" do
      {:ok, _} = start_supervised({PorticoBuffer, []})

      new_rate = :timer.hours(24)
      new_state = PorticoBuffer.update_rate(new_rate)
      
      assert new_state.rate == new_rate
    end

    test "Adding an atom to the queue" do
      {:ok, _} = start_supervised({PorticoBuffer, []})

      atom = %HiveAtom{}
      new_state = PorticoBuffer.add_atom(atom)
      
      assert length(new_state.atoms) == 1
    end
  end
end