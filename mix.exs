defmodule TestMatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_match,
      version: "1.2.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test,
        "coveralls.html": :test, "coveralls.travis": :test]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:excoveralls, github: "parroty/excoveralls", only: :test},
      {:inch_ex, only: :docs}
    ]
  end

  defp description() do
    "Recursive matching"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Anastasiya Dyachenko"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/Apelsinka223/test_match"}
    ]
  end
end
