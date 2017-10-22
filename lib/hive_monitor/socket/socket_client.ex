defmodule HiveMonitor.SocketClient do
  alias Phoenix.Channels.GenSocketClient
  import HiveMonitor.Router, only: [route: 1]
  require Logger
  @behaviour GenSocketClient
  @moduledoc false

  def start_link() do
    token = System.get_env("HIVE_SOCKET_TOKEN") ||
        Application.get_env(:hive_monitor, :hive_socket_token) ||
        "no key"
    token = URI.encode(token)
    GenSocketClient.start_link(
          __MODULE__,
          Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
          #"ws://localhost:4000/socket/websocket?token=#{token}"
          "wss://hive.explo.org/socket/websocket?token=#{token}"
        )
  end

  def init(url) do
    {:connect, url, %{}}
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end


  def handle_connected(transport, state) do
    Logger.info("connected")
    GenSocketClient.join(transport, "atom:create")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("disconnected: #{inspect reason}, #{inspect state}")
    Process.send_after(self(), :connect, :timer.seconds(1))
    {:ok, state}
  end

  def handle_joined(topic, _payload, _transport, state) do
    Logger.info("joined the topic #{topic}")
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("join error on the topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message("atom:create", "created", payload, _transport, state) do
    route(payload)
    {:ok, state}
  end
  def handle_message(topic, event, payload, _transport, state) do
    Logger.warn("message on topic #{topic}: #{event} #{inspect payload}")
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    Logger.warn("reply on topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting")
    {:connect, state}
  end
  def handle_info({:join, topic}, transport, state) do
    Logger.info("joining the topic #{topic}")
    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        Logger.error("error joining the topic #{topic}: #{inspect reason}")
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))
      {:ok, _ref} -> :ok
    end

    {:ok, state}
  end
  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

  def handle_call(_msg, _from, _transport, state) do
    {:ok, state}
  end
end
