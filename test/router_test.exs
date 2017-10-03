defmodule RouterTest do
  use ExUnit.Case, async: true

  setup do
    triplet = {"test_application","test_process","test_context"}
    handler = HiveMonitor.GenericHandler
    handler2 = HiveMonitor.FakeHandler
    {
      :ok,
      triplet: triplet,
      handler: handler,
      handler2: handler2
    }
    
  end

  describe "Test adding + removing handlers" do
    test "Known triplets is returned by add_handler and remove_handler", %{triplet: triplet, handler: handler} do
      known_triplets = HiveMonitor.Router.known_triplets()
      refute Enum.empty? known_triplets

      added_triplets = HiveMonitor.Router.add_handler(triplet, handler)
      assert added_triplets == known_triplets

      removed_triplets = HiveMonitor.Router.remove_handler(triplet, handler)
      known_triplets = HiveMonitor.Router.known_triplets()
      assert removed_triplets == known_triplets
    end

    test "Adding a handler modifies known triplets with a new entry", %{triplet: triplet, handler: handler} do
      known_triplets = HiveMonitor.Router.known_triplets()
      added_triplets = HiveMonitor.Router.add_handler(triplet, handler)
      assert {:ok, [HiveMonitor.GenericHandler]} == Map.fetch(added_triplets, triplet)
      refute known_triplets == added_triplets
    end
    
    test "Removing a unique handler removes the triplet from known_triplets", %{triplet: triplet, handler: handler} do
      HiveMonitor.Router.add_handler(triplet, handler)
      known_triplets = HiveMonitor.Router.remove_handler(triplet, handler)

      assert :error == Map.fetch(known_triplets, triplet)
    end
    
    test "Removing a non-unique handler keeps the triplet entry", %{triplet: triplet, handler: handler, handler2: handler2} do
      HiveMonitor.Router.add_handler(triplet, handler)
      HiveMonitor.Router.add_handler(triplet, handler2)
      known_triplets = HiveMonitor.Router.remove_handler(triplet, handler2)

      assert {:ok, [handler]} == Map.fetch(known_triplets, triplet)
    end
  end
  
end
