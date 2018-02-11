defmodule Bip32.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bip32,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:cryptex, "~> 0.0.1"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:libsecp256k1, [github: "mbrix/libsecp256k1", manager: :rebar]}
    ]
  end
end
