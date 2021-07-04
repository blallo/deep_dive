defmodule DeepDive.MixProject do
  use Mix.Project

  def project do
    [
      app: :deep_dive,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
    ]
  end
end
