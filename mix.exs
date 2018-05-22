defmodule HiveMonitor.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hive_monitor,
      name: "HIVE Monitor",
      source_url: "https://bitbucket.org/explo/hive-monitor",
      version: "0.5.13",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
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

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:explo_comm, git: "git@bitbucket.org:explo/explo-comm.git"},
      {:hive_service, git: "git@bitbucket.org:explo/hive-service.git"},
      {:httpoison, "~> 0.13"},
      {:logger_file_backend, "~> 0.0.10"},
      {:phoenix, "~> 1.3"},
      {:phoenix_gen_socket_client, "~> 1.2.0"},
      {:poison, "~> 3.1"},
      {:websocket_client, github: "sanmiguel/websocket_client"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]
end
