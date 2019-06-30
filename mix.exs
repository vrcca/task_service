defmodule TaskService.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_service,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger],
      mod: {TaskService.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
