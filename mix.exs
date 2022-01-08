defmodule ExUnitSpan.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_unit_span,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:jason, "~> 1.0"}]
  end
end
