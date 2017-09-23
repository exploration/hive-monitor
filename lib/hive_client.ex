defmodule HiveClient do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      worker(HiveClient.SocketClient, []),

      # Also start any "cron" tasks we want to run concurrent with Atom synching
      cron_child("/bin/echo", ["ping"], :timer.seconds(60), true, "test1"),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HiveClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cron_child(cmd, args, rate, run_on_start, id) do
    Supervisor.child_spec( { HiveClient.CronServer, 
        %HiveClient.CronServer.State{ 
            cmd: cmd, args: args, rate: rate, run_on_start: run_on_start} 
        }, 
        id: id
    )
  end
end
