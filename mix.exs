defmodule HiveMonitor.Mixfile do
  use Mix.Project

  def project do
    [app: :hive_monitor,
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
      mod: {HiveMonitor, []},
      extra_applications: [:logger]
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
      {:phoenix, "~> 1.3"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13"},
      {:explo, git: "https://bitbucket.org/explo/explo-elixir-utilities.git"}
    ]
  end
end
