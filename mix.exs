defmodule Kukotbot.Mixfile do
  use Mix.Project

  def project do
    [app: :kukotbot,
     version: "0.1.0",
     elixir: "~> 1.11",
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
    [{:distillery, "~> 2.0"},
     {:tzdata, "~> 1.1.1"},
     {:plug_cowboy, "~> 2.6.0"},
     {:httpoison, "~> 1.8.2"},
     {:poison, "~> 5.0"},
     {:exml, "~> 0.1.1"}]
  end
end
