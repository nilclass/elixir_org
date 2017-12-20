defmodule Org.Parser do
  defstruct doc: %Org.Document{}, mode: nil

  @type t :: %Org.Parser{
    doc: Org.Document.t,
    mode: :paragraph | :table | nil,
  }

  @moduledoc ~S"""
  Parses a text or list of tokens into an `Org.Document`.

  By calling `parse/1`, the lexer is invoked first.
  To parse a file that has already been lexed, pass the tokens to `parse_tokens/2` directly.
  """

  @spec parse(String.t) :: Org.Document.t
  def parse(text) do
    text
    |> Org.Lexer.lex
    |> parse_tokens
  end

  @spec parse_tokens(Org.Parser.t, list(Org.Lexer.token)) :: Org.Document.t
  def parse_tokens(parser \\ %Org.Parser{}, tokens)

  def parse_tokens(parser, []) do
    parser
    |> Map.get(:doc)
    |> Org.Document.reverse_recursive
  end

  def parse_tokens(parser, [token | rest]) do
    token
    |> parse_token(parser)
    |> parse_tokens(rest)
  end

  defp parse_token({:comment, comment}, parser) do
    %Org.Parser{doc: Org.Document.add_comment(parser.doc, comment)}
  end

  defp parse_token({:section_title, level, title}, parser) do
    %Org.Parser{doc: Org.Document.add_subsection(parser.doc, level, title)}
  end

  defp parse_token({:empty_line}, parser) do
    %Org.Parser{parser | mode: nil}
  end

  defp parse_token({:text, line}, parser) do
    doc = if parser.mode == :paragraph do
      Org.Document.update_content(parser.doc, fn paragraph ->
        Org.Paragraph.prepend_line(paragraph, line)
      end)
    else
      Org.Document.prepend_content(parser.doc, Org.Paragraph.new([line]))
    end

    %Org.Parser{parser | doc: doc, mode: :paragraph}
  end

  defp parse_token({:table_row, cells}, parser) do
    doc = if parser.mode == :table do
      Org.Document.update_content(parser.doc, fn table ->
        Org.Table.prepend_row(table, cells)
      end)
    else
      Org.Document.prepend_content(parser.doc, Org.Table.new([cells]))
    end

    %Org.Parser{parser | doc: doc, mode: :table}
  end
end
