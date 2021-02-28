defmodule HiveMonitor.CronServer.Cron do
  @moduledoc """
  System state + type definitions for `CronServer`.
  """

  @enforce_keys [:name]
  defstruct [
    :name,
    :tref,
    module: System,
    fun: :cmd,
    args: ["/bin/echo", "hello world"],
    rate: :timer.minutes(60)
  ]

  @typedoc """
  A "Cron" is a task to perform. 

  This can be a system call, or any Elixir MFA (Module, Function, Argument).
  """
  @type t :: %__MODULE__{
          name: String.t(),
          module: module(),
          fun: function(),
          args: [String.t()],
          rate: integer(),
          tref: :timer.tref()
        }
end
