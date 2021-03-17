defmodule TestMatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_match,
      version: "3.0.1",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev},
      {:excoveralls, github: "parroty/excoveralls", only: :test},
      {:inch_ex, "~> 2.0", only: :docs}
    ]
  end

  defp description() do
    "Recursive matching"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", ".formatter.exs"],
      maintainers: ["Anastasiya Dyachenko"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Apelsinka223/test_match"}
    ]
  end
end
