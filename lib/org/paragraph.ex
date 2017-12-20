defmodule Org.Paragraph do
  defstruct lines: []

  @moduledoc ~S"""
  Represents an uninterrupted list of lines. Paragraphs are separated by one or more newlines.

  Example:
      iex> doc = Org.Parser.parse("Foo\nBar\n\nBaz")
      iex> doc.contents
      [%Org.Paragraph{lines: ["Foo", "Bar"]}, %Org.Paragraph{lines: ["Baz"]}]
  """

  @doc "Constructs a new paragraph from given list of lines"
  def new(lines) do
    %Org.Paragraph{lines: lines}
  end

  @doc "Prepends a line to the list of lines. Used by the parser."
  def prepend_line(paragraph, line) do
    %Org.Paragraph{paragraph | lines: [line | paragraph.lines]}
  end
end

defimpl Org.Content, for: Org.Paragraph do
  def reverse_recursive(paragraph) do
    %Org.Paragraph{paragraph | lines: Enum.reverse(paragraph.lines)}
  end
end
