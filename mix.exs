defmodule Org.Mixfile do
  use Mix.Project

  def project do
    [
      app: :org,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),
      description: "org-mode parser",
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Niklas Cathor"],
      links: %{
        "GitHub" => "https://github.com/nilclass/elixir_org"
      }
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5.1"}
    ]
  end
end
