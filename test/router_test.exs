defmodule RouterTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.Router

  setup do
    atom = %{
      "application" => "test_application",
      "context" => "test_context",
      "process" => "test_process",
      "data" => ~s({"hello":"world"})
    }
    triplet = {atom["application"], atom["context"], atom["process"]}
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

  describe "test adding + removing handlers" do
    test "Known triplets/config is a map" do
      {:ok, _} = start_supervised({Router, [known_triplets: %{}]})
      config = Router.get_config()

      assert is_map(config)
      assert Enum.count(config) == 0
    end

    test "loads the initial config via passed params",
        %{triplet: triplet, handler: handler} do
      {:ok, _} = start_supervised(
        {Router, [known_triplets: %{triplet => [handler]}]}
      )

      config = Router.get_config()

      assert Enum.count(config) == 1
      assert Map.fetch!(config, triplet) == [handler]

    end

    test "known triplets is returned by add_handler and remove_handler", 
        %{triplet: triplet, handler: handler} do
      {:ok, _} = start_supervised({Router, [known_triplets: %{}]})

      added_triplets = Router.add_handler(triplet, handler)
      known_triplets = Router.get_config()
      refute Enum.empty? known_triplets
      assert added_triplets == known_triplets

      removed_triplets = Router.remove_handler(triplet, handler)
      known_triplets = Router.get_config()
      assert removed_triplets == known_triplets
      assert %{} == known_triplets
    end

    test "Adding a handler modifies known triplets with a new entry",
        %{handler: handler, triplet: triplet} do
      {:ok, _} = start_supervised({Router, [known_triplets: %{}]})

      added_triplets = Router.add_handler(triplet, handler)

      assert {:ok, [handler]} == Map.fetch(added_triplets, triplet)
    end
    
    test "Removing a unique handler removes the triplet from known_triplets",
        %{handler: handler, triplet: triplet} do
      {:ok, _} = start_supervised({Router, [known_triplets: %{}]})

      Router.add_handler(triplet, handler)
      known_triplets = Router.remove_handler(triplet, handler)

      assert :error == Map.fetch(known_triplets, triplet)
    end
    
    test "Removing a non-unique handler keeps the triplet entry",
        %{triplet: triplet, handler: handler, test_handler: test_handler} do
      {:ok, _} = start_supervised({Router, [known_triplets: %{}]})

      Router.add_handler(triplet, handler)
      Router.add_handler(triplet, test_handler)
      known_triplets = Router.remove_handler(triplet, test_handler)

      assert {:ok, [handler]} == Map.fetch(known_triplets, triplet)
    end
  end

end
