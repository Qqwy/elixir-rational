defmodule Rational.Mixfile do
  use Mix.Project

  def project do
    [app: :ratio,
     version: "1.2.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package,
     description: description
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
      {:earmark, ">= 0.0.0", only: [:dev]}, # Markdown, dependency of ex_doc
      {:ex_doc, "~> 0.14", only: [:dev]},    # Documentation for Hex.pm
      {:numbers, "~> 2.0"} # Generic arithmetic dispatching.
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*",  "LICENSE*"],
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

  # Can be overridden to allow different float precisions.
  Application.put_env(:ratio, :max_float_to_rational_digits, 10)


end
