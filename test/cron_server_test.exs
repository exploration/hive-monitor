defmodule CronServerTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.CronServer
  alias HiveMonitor.CronServer.Cron

  setup do
    {:ok, cron_name: "test"}
  end

  describe "cron CRUD: " do
    test "crons state is a list of Crons", %{cron_name: cron_name} do
      {:ok, _} = start_supervised({CronServer, []})

      CronServer.add_cron(%Cron{name: cron_name})
      
      crons_list = CronServer.list_crons()
      assert is_list(crons_list)

      first_cron = Enum.at(crons_list, 0)
      assert first_cron.__struct__ == Cron
    end

    test "crons config is a list of proper maps", %{cron_name: cron_name} do
      {:ok, _} = start_supervised({CronServer, []})

      CronServer.add_cron(%Cron{name: cron_name})
      config = CronServer.get_config()

      assert is_list(config)

      rando_config = Enum.random(config)
      assert %{name: _, module: _, fun: _, args: _, rate: _} = rando_config
    end

    test "cronserver loads the passed config on start",
        %{cron_name: cron_name} do
      cron = %Cron{name: cron_name, tref: nil}
      cron_map = Map.from_struct(cron)

      {:ok, _} = start_supervised({CronServer, [crons: [cron_map]]})

      crons = CronServer.list_crons()
      assert Enum.at(crons, 0) == cron
    end

    test "adding a new Cron adds that cron to the Cron list",
        %{cron_name: cron_name} do
      {:ok, _} = start_supervised({CronServer, []})

      CronServer.add_cron(%Cron{name: cron_name})
      CronServer.add_cron(%Cron{name: cron_name <> "woo"})
      crons = CronServer.list_crons()
      assert Enum.count(crons) == 2

      matches = Enum.find(crons, :nothing, &(&1.name == cron_name)) 
      refute matches == :nothing
    end

    test "can't add a duplicate Cron by name", %{cron_name: cron_name} do
      {:ok, _} = start_supervised({CronServer, []})

      cron = %Cron{name: cron_name}
      CronServer.add_cron(cron)

      assert {:error, _} = CronServer.add_cron(cron)
    end

    test "adding a new Cron returns a Cron with a timer reference" do
      {:ok, _} = start_supervised({CronServer, []})

      cron = %Cron{name: "timer_reference_test"}
      assert is_nil(cron.tref)

      updated_cron = CronServer.add_cron(cron)
      assert {:interval, ref} = updated_cron.tref
      assert is_reference(ref)
    end

    test "deleting a Cron removes it from the state",
        %{cron_name: cron_name} do
      {:ok, _} = start_supervised({CronServer, []})

      CronServer.add_cron(%Cron{name: cron_name})
      CronServer.delete_cron(cron_name)
      crons = CronServer.list_crons

      assert Enum.find(crons, :nothing, &(&1.name == cron_name)) == :nothing
    end

    test "updating a Cron's time", %{cron_name: cron_name} do
      {:ok, _} = start_supervised({CronServer, []})

      cron = %Cron{name: cron_name, rate: :timer.seconds(12)}
      CronServer.add_cron(cron)
      updated_cron = CronServer.update_rate(cron.name, :timer.seconds(54))

      assert updated_cron.rate == :timer.seconds(54)
      refute cron.rate == updated_cron.rate
    end
  end

  describe "cron execution: " do
    test "execute a Cron" do
      {:ok, _} = start_supervised({CronServer, []})

      cron = %Cron{
        name: "execute", 
        module: __MODULE__, fun: :ping, args: [self(), :execute]
      }
      CronServer.execute_cron(cron)

      assert_receive(:execute)
    end

    test "execute a Cron at the moment that it's added" do
      {:ok, _} = start_supervised({CronServer, []})

      rate = 1 # milliseconds
      cron = %Cron{
        name: "add_cron", 
        module: __MODULE__, fun: :ping, args: [self(), :add_cron], rate: rate
      }
      CronServer.add_cron(cron)

      # It should take 1ms to start the timer, then another 1ms to run the
      # function. We are assuming that it'll take at most 50ms to process a
      # reply. (It hasn't failed in thousands of tests)
      assert_receive(:add_cron, 50)
    end
  end

  def ping(pid, msg) do
    Process.send(pid, msg, [])
  end
end
