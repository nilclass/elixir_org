defmodule Org do
  @moduledoc """
  This package implements an org-mode lexer and parser.

  org-mode is the markup language used by the powerful [org mode package for emacs](http://orgmode.org/).

  This implementation supports only a small subset of the syntax at this point, but can already be useful for extracting information from well-formed documents.

  Features supported are:
  - Comments
  - (nested) Sections
  - Paragraphs
  - Tables
  """

  @doc "Loads a from a file at given path"
  @spec load_file(String.t) :: Org.Document.t
  def load_file(path) do
    {:ok, text} = File.read(path)
    Org.Parser.parse(text)
  end

  @doc "Extracts a section at the given path of titles"
  @spec section(Org.Document.t, list(String.t)) :: Org.Section.t
  def section(doc, path) do
    Org.Section.find_by_path(doc.sections, path)
  end

  @doc "Extracts all tables from the given section or document"
  def tables(container) do
    for %Org.Table{} = t <- Org.contents(container), do: t
  end

  def contents(%Org.Document{} = doc) do
    Org.Document.contents(doc)
  end

  def contents(%Org.Section{} = section) do
    Org.Section.contents(section)
  end

  def print_tree(doc) do
    print_sections(doc.sections, 0)
  end

  def print_sections(sections, indent) do
    indent_string = Enum.join(for i <- 0..indent, i != 0, do: " ")
    for section <- sections do
      IO.puts "#{indent_string}Section: #{section.title}"
      print_sections(section.children, indent + 2)
    end
  end
end
