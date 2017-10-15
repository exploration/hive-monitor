defmodule CronServerTest do
  use ExUnit.Case
  alias HiveMonitor.CronServer
  alias HiveMonitor.CronServer.Cron

  setup do
    { :ok, cron_name: "test" }
  end

  describe "Cron CRUD" do
    test "Crons state is a list of Crons", %{cron_name: cron_name} do
      CronServer.add_cron(%Cron{name: cron_name})
      crons_list = CronServer.list_crons()
      assert is_list(crons_list)

      first_cron = Enum.at(crons_list, 0)
      assert first_cron.__struct__ == Cron
    end

    test "Adding a new Cron adds that cron to the Cron list", %{cron_name: cron_name} do
      CronServer.add_cron(%Cron{name: cron_name})
      initial_list = CronServer.list_crons
      CronServer.add_cron(%Cron{name: "snarfblatt"})
      updated_list = CronServer.list_crons
      
      assert Enum.count(initial_list) + 1 == Enum.count(updated_list)
      refute Enum.find(updated_list, :nothing, &(&1.name == cron_name)) == :nothing
    end

    test "Can't add a duplicate Cron by name", %{cron_name: cron_name} do
      CronServer.add_cron(%Cron{name: cron_name})
      assert {:error, _} = CronServer.add_cron(%Cron{name: cron_name})
    end

    test "Deleting a Cron removes it from the list", %{cron_name: cron_name} do
      CronServer.add_cron(%Cron{name: cron_name})
      CronServer.delete_cron(cron_name)
      updated_list = CronServer.list_crons

      assert Enum.find(updated_list, :nothing, &(&1.name == cron_name)) == :nothing
    end

    test "Updating a Cron's time", %{cron_name: cron_name} do
      cron = %Cron{name: cron_name, rate: :timer.seconds(12)}
      CronServer.add_cron(cron)
      updated_cron = CronServer.update_rate(cron.name, :timer.seconds(54))

      assert updated_cron.rate == :timer.seconds(54)
      refute cron.rate == updated_cron.rate
    end
  end
end
