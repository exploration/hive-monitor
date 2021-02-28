defmodule HiveMonitor.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hive_monitor,
      name: "HIVE Monitor",
      source_url: "https://bitbucket.org/explo/hive-monitor",
      version: "1.0.2",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
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
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:explo_comm, git: "git@bitbucket.org:explo/explo-comm.git"},
      {:faker, "~> 0.16"},
      {:hive_service, git: "git@bitbucket.org:explo/hive-service.git"},
      {:httpoison, "~> 1.6"},
      {:logger_file_backend, "~> 0.0.10"},
      {:phoenix, "~> 1.3"},
      {:phoenix_gen_socket_client, "~> 4.0.0"},
      # Required by gen_socket_client to be explicitly invoked:
      {:websocket_client, "~> 1.2"},
      {:jason, "~> 1.2"}
    ]
  end

  def docs do
    [
      main: "HiveMonitor"
      # extras: [""]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]
end
