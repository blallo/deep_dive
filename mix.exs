defmodule DeepDive.MixProject do
  use Mix.Project

  def project do
    [
      app: :deep_dive,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Deep Dive",
      source_url: "https://github.com/blallo/deep_dive",
      docs: docs(),
      description: description(),
      package: package()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:credo, "~> 1.5.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [main: "DeepDive", extras: ["README.md"]]
  end


  defp description() do
    "Debug utility to explore nested data structures in elixir"
  end

  defp package() do
    [
      licenses: ["GPL"],
      links: %{"GitHub" => "https://github.com/blallo/deep_dive"}
    ]
  end
end
