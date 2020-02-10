defmodule Detour.MixProject do
  use Mix.Project

  def project do
    [
      app: :detour,
      version: "0.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: { Detour.Application, [] }
    ]
  end

  defp deps do
    [
      { :gen_smtp, "~> 0.15" },

      #
      # test
      #

      { :dialyxir, "~> 1.0.0-rc", only: [:dev], runtime: false }
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      plt_core_path: "./_build/#{Mix.env()}"
    ]
  end
end
