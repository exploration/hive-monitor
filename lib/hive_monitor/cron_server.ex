defmodule HiveMonitor.CronServer do
  use GenServer

  defmodule State do
    defstruct cmd: "/bin/echo",
        args: ["hello world"],
        rate: :timer.seconds(10),
        run_on_start: false
  end

  # client code
  def start_link(state \\ %State{}) do
    GenServer.start(__MODULE__, state)
  end


  # server code
  def init(state) do
    case state.run_on_start do
      true -> run_and_refresh(state)
      false -> refresh(state)
    end
    {:ok, state}
  end

  def handle_info(:refresh, state) do
    run_and_refresh(state)
    {:noreply, state}
  end


  defp run_and_refresh(state) do
    IO.puts "CronServer refresh every #{state.rate / 1000}s: #{state.cmd} #{state.args}"
    System.cmd(state.cmd, state.args)
    refresh(state)
  end

  defp refresh(state) do
    Process.send_after(self(), :refresh, state.rate)    
  end
end
