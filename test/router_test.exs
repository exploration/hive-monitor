defmodule RouterTest do
  use ExUnit.Case
  alias HiveMonitor.Router

  setup do
    atom = %{
      "application" => "test_application",
      "context" => "test_context",
      "process" => "test_process",
      "data" => ~s({"hello":"world"})
    }
    triplet = {atom["application"],atom["context"],atom["process"]}
    handler = HiveMonitor.GenericHandler
    test_handler = HiveMonitor.TestHandler

    {
      :ok,
      triplet: triplet,
      handler: handler,
      test_handler: test_handler,
      atom: atom
    }
    
  end

  describe "Test adding + removing handlers: " do
    test "Known triplets is a map" do
      assert is_map Router.known_triplets()
    end

    test "Known triplets is returned by add_handler and remove_handler", %{triplet: triplet, handler: handler} do

      added_triplets = Router.add_handler(triplet, handler)
      known_triplets = Router.known_triplets()
      refute Enum.empty? known_triplets
      assert added_triplets == known_triplets

      removed_triplets = Router.remove_handler(triplet, handler)
      known_triplets = Router.known_triplets()
      assert removed_triplets == known_triplets
    end

    test "Adding a handler modifies known triplets with a new entry", %{handler: handler} do
      triplet = {"router_test","handler","modifies_known_triplets_test"}
      added_triplets = Router.add_handler(triplet, handler)
      assert {:ok, [handler]} == Map.fetch(added_triplets, triplet)
    end
    
    test "Removing a unique handler removes the triplet from known_triplets", %{handler: handler} do
      triplet = {"router_test","handler","remove_unique_test"}
      Router.add_handler(triplet, handler)
      known_triplets = Router.remove_handler(triplet, handler)

      assert :error == Map.fetch(known_triplets, triplet)
    end
    
    test "Removing a non-unique handler keeps the triplet entry", %{triplet: triplet, handler: handler, test_handler: test_handler} do
      Router.add_handler(triplet, handler)
      Router.add_handler(triplet, test_handler)
      known_triplets = Router.remove_handler(triplet, test_handler)

      assert {:ok, [handler]} == Map.fetch(known_triplets, triplet)
    end
  end


  describe "Test routing: " do
    test "Routing an atom returns a list of task PIDs", %{atom: atom} do
      pid_list = Router.route(atom)
      assert is_list pid_list
      assert is_pid List.first(pid_list)
    end

    test "Routing to an atom with x handlers returns a pid_list of length x", %{atom: atom, triplet: triplet, handler: handler, test_handler: test_handler} do
      Router.add_handler(triplet, handler)
      Router.add_handler(triplet, test_handler)

      pid_list = Router.route(atom)
      assert Enum.count(pid_list) == 2
    end
  end

end
