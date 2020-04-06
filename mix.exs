defmodule Kukotbot.Mixfile do
  use Mix.Project

  def project do
    [app: :kukotbot,
     version: "0.1.0",
     elixir: "~> 1.9",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:tzdata, :logger, :cowboy, :plug, :httpoison, :poison],
     mod: {Kukotbot, []}]
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
    [{:tzdata, "~> 1.0.1"},
     {:cowboy, "~> 2.6.0"},
     {:plug, "~> 1.8.0"},
     {:httpoison, "~> 1.6.0"},
     {:poison, "~> 4.0"},
     {:exml, "~> 0.1.1"}]
  end
end
