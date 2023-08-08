defmodule Rational.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ratio,
      version: "4.0.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      source_url: "https://github.com/qqwy/elixir-rational"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    extra_applications =
      case Mix.env() do
        :test -> [:stream_data, :logger]
        _ -> [:logger]
      end

    [
      applications: [
        :numbers
      ],
      extra_applications: extra_applications
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # Markdown, dependency of ex_doc
      {:earmark, ">= 1.0.0", only: [:dev]},
      # Documentation for Hex.pm
      {:ex_doc, "~> 0.20", only: [:dev]},
      # Generic arithmetic dispatching.
      {:numbers, "~> 5.2.0"},
      # If Decimal number support is required
      {:decimal, "~> 1.6 or ~> 2.0", optional: true},
      {:stream_data, "~> 0.1", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Qqwy/WM"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/qqwy/elixir-rational"}
    ]
  end

  defp description do
    """
      This library allows you to use Rational numbers in Elixir, to enable exact calculations with all numbers big and small.
    """
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md": [title: "Guide/Readme"]
      ]
    ]
  end
end
