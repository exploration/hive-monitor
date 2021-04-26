defmodule HiveMonitor.SocketClient do
  @moduledoc """
  Forward atoms in real time from the HIVE server.

  Most of the functions in here are boilerplate. The one that handles the call
  to `atom:create` is where most of the magic happens in this piece.
  """

  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient

  require Logger
  import HiveMonitor.Router, only: [route: 1]

  @doc false
  def start_link do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      "wss://hive.explo.org/socket/websocket"
    )
  end

  @doc false
  def init(url) do
    token = Application.get_env(:hive_monitor, :hive_socket_token, "no token")

    {:connect, url, [token: token], %{first_join: true}}
  end

  @doc false
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 20_000
    }
  end

  @doc false
  def handle_connected(transport, state) do
    log(:info, "#{HiveMonitor.application_name()} connected")
    GenSocketClient.join(transport, "atom:create")
    {:ok, state}
  end

  @doc false
  def handle_disconnected(reason, state) do
    log(
      :error,
      "#{HiveMonitor.application_name()} disconnected: #{inspect(reason)}, #{inspect(state)}"
    )

    Process.send_after(self(), :connect, :timer.seconds(1))
    {:ok, state}
  end

  @doc false
  def handle_joined(topic, _payload, _transport, state) do
    log(:info, "#{HiveMonitor.application_name()} joined the topic #{topic}")

    {:ok, state}
  end

  @doc false
  def handle_join_error(topic, payload, _transport, state) do
    log(
      :error,
      "#{HiveMonitor.application_name()} join error on the topic #{topic}: #{inspect(payload)}"
    )

    {:ok, state}
  end

  @doc false
  def handle_channel_closed(topic, payload, _transport, state) do
    log(
      :error,
      "#{HiveMonitor.application_name()} disconnected from the topic #{topic}: #{inspect(payload)}"
    )

    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  @doc """
  This callback is the one that matters.

  When an `atom:create` message is received from HIVE, this module
  will send it to `HiveMonitor.Router.route/1`.
  """
  def handle_message("atom:create", "created", payload, _transport, state) do
    route(payload)
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    log(
      :warn,
      "#{HiveMonitor.application_name()} message on topic #{topic}: #{event} #{inspect(payload)}"
    )

    {:ok, state}
  end

  @doc false
  def handle_reply(topic, _ref, payload, _transport, state) do
    log(:warn, "#{HiveMonitor.application_name()} reply on topic #{topic}: #{inspect(payload)}")

    {:ok, state}
  end

  @doc false
  def handle_info(:connect, _transport, state) do
    log(:info, "#{HiveMonitor.application_name()} connecting")

    {:connect, state}
  end

  @doc false
  def handle_info({:join, topic}, transport, state) do
    log(:info, "#{HiveMonitor.application_name()} joining the topic #{topic}")

    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        log(:error, "error joining the topic #{topic}: #{inspect(reason)}")

        Process.send_after(self(), {:join, topic}, :timer.seconds(1))

      {:ok, _ref} ->
        :ok
    end

    {:ok, state}
  end

  @doc false
  def handle_info(message, _transport, state) do
    log(:warn, "#{HiveMonitor.application_name()} unhandled message #{inspect(message)}")

    {:ok, state}
  end

  @doc false
  def handle_call(_msg, _from, _transport, state) do
    {:noreply, state}
  end

  defp log(:error, message) do
    unless Mix.env() == :test, do: Logger.error(message)
  end

  defp log(:info, message) do
    unless Mix.env() == :test, do: Logger.info(message)
  end

  defp log(:warn, message) do
    unless Mix.env() == :test, do: Logger.warn(message)
  end
end
