defmodule HiveClient.SocketClient do
  alias Phoenix.Channels.GenSocketClient
  require Logger
  @behaviour GenSocketClient
  @moduledoc false

  def start_link() do
    GenSocketClient.start_link(
          __MODULE__,
          Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
          #"ws://localhost:4000/socket/websocket"
          "wss://hive.explo.org/socket/websocket"
        )
  end

  def init(url) do
    {:connect, url, %{}}
  end


  def handle_connected(transport, state) do
    Logger.info("connected")
    GenSocketClient.join(transport, "atom:create")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("disconnected: #{inspect reason}")
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
    Logger.info("ATOM created: #{inspect payload}")
    System.cmd "/usr/bin/osascript", ["-e", "display dialog \"New data received!\nApplication: #{payload["application"]}\nContext: #{payload["context"]}\nProcess: #{payload["process"]}\""]
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
