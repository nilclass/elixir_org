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

  @doc "Loads a document from a file at given path"
  @spec load_file(String.t) :: Org.Document.t
  def load_file(path) do
    {:ok, data} = File.read(path)
    Org.Parser.parse(data)
  end

  @doc "Loads a document from the given source string"
  @spec load_string(String.t) :: Org.Document.t
  def load_string(data) do
    Org.Parser.parse(data)
  end

  @doc ~S"""
  Extracts a section at the given path of titles

  Example:
      iex> doc = Org.load_string("* First\n** Second\n*** Third\n* Fourth\n")
      iex> Org.section(doc, ["First"]).title
      "First"
      iex> Org.section(doc, ["First", "Second", "Third"]).title
      "Third"
      iex> Org.section(doc, ["Fourth"]).title
      "Fourth"
  """
  @spec section(Org.Document.t, list(String.t)) :: Org.Section.t
  def section(doc, path) do
    Org.Section.find_by_path(doc.sections, path)
  end

  @doc ~S"""
  Extracts all tables from the given section or document

  Example:
      iex> doc = Org.load_string("First paragraph\n| x | y |\n| 1 | 7 |\nSecond paragraph")
      iex> Org.tables(doc)
      [%Org.Table{rows: [%Org.Table.Row{cells: ["x", "y"]}, %Org.Table.Row{cells: ["1", "7"]}]}]
  """
  @spec tables(Org.Section.t | Org.Document.t) :: list(Org.Table.t)
  def tables(section_or_document) do
    for %Org.Table{} = t <- Org.contents(section_or_document), do: t
  end

  @doc ~S"""
  Extracts all paragraphs from the given section or document

  Example:
      iex> doc = Org.load_string("First paragraph\n| x | y |\n| 1 | 7 |\nSecond paragraph")
      iex> Org.paragraphs(doc)
      [%Org.Paragraph{lines: ["First paragraph"]}, %Org.Paragraph{lines: ["Second paragraph"]}]
  """
  @spec tables(Org.Section.t | Org.Document.t) :: list(Org.Paragraph.t)
  def paragraphs(section_or_document) do
    for %Org.Paragraph{} = p <- Org.contents(section_or_document), do: p
  end

  @doc "Extracts all contents from given section or document"
  @spec contents(Org.Document.t | Org.Section.t) :: list(Org.Content.t)
  def contents(section_or_document)
  def contents(%Org.Document{} = doc) do
    Org.Document.contents(doc)
  end

  def contents(%Org.Section{} = section) do
    Org.Section.contents(section)
  end
end
