defmodule Detour.MixProject do
  use Mix.Project

  def project do
    [
      app: :detour,
      version: "0.2.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      package: package()
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
      { :gen_smtp, "~> 1.0" },

      #
      # test
      #

      { :dialyxir, "~> 1.0", only: [:dev], runtime: false },

      { :ex_doc, ">= 0.0.0", only: [:dev], runtime: false }
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      plt_core_path: "./_build/#{Mix.env()}"
    ]
  end

  defp package do
    %{
      description: "Easily test email deliverability using simple-to-use assertions against a real SMTP server",
      maintainers: ["Anthony Smith"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/malomohq/detour-elixir",
        "Made by Malomo - Post-purchase experiences that customers love": "https://gomalomo.com"
      }
    }
  end
end
