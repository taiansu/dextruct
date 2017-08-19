defmodule Dextruct.Mixfile do
  use Mix.Project

  def project do
    [
      app: :dextruct,
      version: "1.0.0",
      elixir: "~> 1.5",
      name: "Dextruct",
      source_url: "https://github.com/taiansu/dextruct",
      homepage_url: "https://taiansu.github.io/dextruct",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def description do
    """
    Destructing assignment with `<~`
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Tai An Su"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub": "https://github.com/taiansu/dextruct",},

      # Docs
       name: :dextruct,
       source_url: "https://github.com/taiansu/dextruct",
       docs: [main: "Dextruct", # The main page in the docs
              extras: ["README.md"]]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: [:dev, :test], runtime: false},
    ]
  end
end
