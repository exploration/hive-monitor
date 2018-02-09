defmodule RouterTest do
  use ExUnit.Case, async: true
  require Logger
  import ExUnit.CaptureLog
  alias HiveMonitor.Router

  setup do
    atom_map = %{
      "application" => "test_application",
      "context" => "test_context",
      "process" => "test_process",
      "data" => ~s({"hello":"world"})
    }

    triplet = {
      atom_map["application"],
      atom_map["context"],
      atom_map["process"]
    }

    handler = HiveMonitor.TestHandler
    alt_handler = HiveMonitor.GenericHandler

    {
      :ok,
      triplet: triplet, handler: handler, alt_handler: alt_handler, atom_map: atom_map
    }
  end

  describe "test adding + removing handlers: " do
    test "config is a map" do
      {:ok, _} = start_supervised({Router, [config: %{}]})
      config = Router.get_config()

      assert is_map(config)
      assert Enum.empty?(config)
    end

    test "loads the initial config via passed params", %{triplet: triplet, handler: handler} do
      {:ok, _} = start_supervised({Router, [config: %{triplet => [handler]}]})

      config = Router.get_config()

      assert Enum.count(config) == 1
      assert Map.fetch!(config, triplet) == [handler]
    end

    test "A config is returned by add_handler and remove_handler", %{
      triplet: triplet,
      handler: handler
    } do
      {:ok, _} = start_supervised({Router, [config: %{}]})

      added_triplets = Router.add_handler(triplet, handler)
      config = Router.get_config()
      refute Enum.empty?(config)
      assert added_triplets == config

      removed_triplets = Router.remove_handler(triplet, handler)
      config = Router.get_config()
      assert removed_triplets == config
      assert %{} == config
    end

    test "Adding a handler modifies the config with a new entry", %{
      handler: handler,
      triplet: triplet
    } do
      {:ok, _} = start_supervised({Router, [config: %{}]})

      added_triplets = Router.add_handler(triplet, handler)

      assert {:ok, [handler]} == Map.fetch(added_triplets, triplet)
    end

    test "Removing a unique handler removes the triplet from the config", %{
      handler: handler,
      triplet: triplet
    } do
      {:ok, _} = start_supervised({Router, [config: %{}]})

      Router.add_handler(triplet, handler)
      config = Router.remove_handler(triplet, handler)

      assert :error == Map.fetch(config, triplet)
    end

    test "Removing a non-unique handler keeps previous triplet entries", %{
      triplet: triplet,
      handler: handler,
      alt_handler: alt_handler
    } do
      {:ok, _} = start_supervised({Router, [config: %{}]})

      Router.add_handler(triplet, handler)
      Router.add_handler(triplet, alt_handler)
      config = Router.remove_handler(triplet, alt_handler)

      assert [handler] == Map.fetch!(config, triplet)
    end
  end

  describe "routing: " do
    test "routing to an atom returns a list of routing statuses", %{
      atom_map: atom_map,
      triplet: triplet,
      handler: handler
    } do
      {:ok, _} = start_supervised({Router, [config: %{}]})
      Router.add_handler(triplet, handler)

      assert [{:ok, :success}] = Router.route(atom_map, :await)
    end

    test "routing to an atom ends up at a handler", %{
      atom_map: atom_map,
      triplet: triplet,
      handler: handler
    } do
      {:ok, _} = start_supervised({Router, [config: %{}]})
      Router.add_handler(triplet, handler)

      atom = HiveAtom.from_map(atom_map)
      capture = capture_log(fn -> Router.route(atom_map, :await) end)

      assert capture =~ "Test Handler: #{inspect(atom)}"
    end
  end
end
