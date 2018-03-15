defmodule StagnantAtomCheckerTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.StagnantAtomChecker

  describe "basic functionality: " do
    test "starts out with two empty sets" do
      {:ok, _} = start_supervised({StagnantAtomChecker, []})
      {:ok, state} = StagnantAtomChecker.get_state()

      assert MapSet.size(state.current) == 0
      assert MapSet.size(state.previous) == 0
    end

    test "adding an atom list" do
      {:ok, _} = start_supervised({StagnantAtomChecker, []})
      {:ok, state} = StagnantAtomChecker.add_atom_list(sample_atoms())

      assert MapSet.size(state.current) == 3
      assert MapSet.size(state.previous) == 0
    end

    test "adding duplicate atoms" do
      {:ok, _} = start_supervised({StagnantAtomChecker, []})
      StagnantAtomChecker.add_atom_list(sample_atoms())
      {:ok, state} = StagnantAtomChecker.add_atom_list(sample_atoms())

      assert MapSet.size(state.current) == 3
    end

    test "adding extra atoms" do
      {:ok, _} = start_supervised({StagnantAtomChecker, []})
      StagnantAtomChecker.add_atom_list(sample_atoms())
      {:ok, state} = StagnantAtomChecker.add_atom_list(extra_atoms())

      assert MapSet.size(state.current) == 4
    end

    test "resetting current state" do
      {:ok, _} = start_supervised({StagnantAtomChecker, []})
      StagnantAtomChecker.add_atom_list(sample_atoms())
      {:ok, state} = StagnantAtomChecker.reset_current()

      assert MapSet.size(state.current) == 0
      assert MapSet.size(state.previous) == 3
    end

    test "stagnant atom check" do
      {:ok, _} = start_supervised({StagnantAtomChecker, []})

      StagnantAtomChecker.add_atom_list(sample_atoms())
      StagnantAtomChecker.reset_current()
      {:ok, state} = StagnantAtomChecker.add_atom_list(extra_atoms())
      {:ok, stagnant_atoms} = StagnantAtomChecker.get_stagnant_atoms()

      assert Enum.count(stagnant_atoms) == 3
      assert MapSet.size(state.current) == 4
      assert Enum.member?(stagnant_atoms, Enum.at(sample_atoms(), 1))
      refute Enum.member?(stagnant_atoms, Enum.at(extra_atoms(), 4))
    end
  end

  def extra_atoms do
    [%HiveAtom{application: 'test4'} | sample_atoms()]
  end

  def sample_atoms do
    [
      %HiveAtom{application: 'test1'},
      %HiveAtom{application: 'test2'},
      %HiveAtom{application: 'test3'}
    ]
  end
end
