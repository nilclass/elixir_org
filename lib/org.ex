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

  @type load_mode :: :document | :tokens

  @doc "Loads a document from a file at given path"
  @spec load_file(String.t, load_mode) :: Org.Document.t
  def load_file(path, load_mode \\ :document) do
    {:ok, data} = File.read(path)
    load_string(data, load_mode)
  end

  @doc "Loads a document from the given source string"
  @spec load_string(String.t, load_mode) :: Org.Document.t
  def load_string(data, load_mode \\ :document)

  def load_string(data, :document) do
    Org.Parser.parse(data)
  end

  def load_string(data, :tokens) do
    Org.Lexer.lex(data)
  end

  @doc ~S"""
  Extracts a section at the given path of titles

  Example:
      iex> doc = Org.load_string(~S{
      ...>* First
      ...>** Second
      ...>*** Third
      ...>* Fourth
      iex>})
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
      iex> doc = Org.load_string(~S{
      ...>First paragraph
      ...>| x | y |
      ...>| 1 | 7 |
      ...>Second paragraph
      ...>})
      iex> Org.tables(doc)
      [%Org.Table{rows: [%Org.Table.Row{cells: ["x", "y"]}, %Org.Table.Row{cells: ["1", "7"]}]}]
  """
  @spec tables(Org.Section.t | Org.Document.t) :: list(Org.Table.t)
  def tables(section_or_document) do
    for %Org.Table{} = table <- Org.contents(section_or_document), do: table
  end

  @doc ~S"""
  Extracts all paragraphs from the given section or document

  Example:
      iex> doc = Org.load_string(~S{
      ...>First paragraph
      ...>| x | y |
      ...>| 1 | 7 |
      ...>Second paragraph
      ...>})
      iex> Org.paragraphs(doc)
      [%Org.Paragraph{lines: ["First paragraph"]}, %Org.Paragraph{lines: ["Second paragraph"]}]
  """
  @spec paragraphs(Org.Section.t | Org.Document.t) :: list(Org.Paragraph.t)
  def paragraphs(section_or_document) do
    for %Org.Paragraph{} = paragraph <- Org.contents(section_or_document), do: paragraph
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
