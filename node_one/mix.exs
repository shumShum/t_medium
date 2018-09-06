defmodule NodeOne.MixProject do
  use Mix.Project

  def project do
    [
      app: :node_one,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {NodeOne, []},
      applications: [:amqp, :httpoison],
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0", override: true},
      {:poison, "~> 4.0"},
      {:amqp, "~> 1.0"},
      {:ranch_proxy_protocol, "~> 2.0", override: true}
    ]
  end
end
