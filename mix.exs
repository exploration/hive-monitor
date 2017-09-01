defmodule HiveClient.Mixfile do
  use Mix.Project

  def project do
    [app: :hive_client,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {HiveClient, []},
      applications: [
       :phoenix_gen_socket_client, :websocket_client
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix_gen_socket_client, "~> 1.2.0"},
      {:websocket_client, github: "sanmiguel/websocket_client"},
      {:poison, "~> 3.1"},
      {:phoenix, "~> 1.3"}
    ]
  end
end
