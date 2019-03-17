defmodule Org.Document do
  defstruct comments: [], sections: [], contents: []

  @type t :: %Org.Document{
    comments: list(String.t),
    sections: list(Org.Section.t),
    contents: list(Org.Content.t),
  }

  @moduledoc ~S"""
  Represents an interpreted document.

  Documents are organized as a tree of sections, each of which has a title and optional contents.
  The document can also have contents at the top level.
  """

  @doc "Retrieve current contents of document"
  def contents(%Org.Document{contents: contents}) do
    contents
  end

  @doc "Prepend a comment to the list of comments. Used by the parser"
  def add_comment(doc, comment) do
    %Org.Document{doc | comments: [comment | doc.comments]}
  end

  @doc "Prepend a subsection at the given level."
  def add_subsection(doc, level, title)

  def add_subsection(doc, 1, title) do
    %Org.Document{doc | sections: [%Org.Section{title: title} | doc.sections]}
  end

  def add_subsection(doc, level, title) do
    {current, rest} = case doc.sections do
                        [current | rest] -> {current, rest}
                        [] -> {%Org.Section{}, []}
                      end
    %Org.Document{doc | sections: [Org.Section.add_nested(current, level - 1, %Org.Section{title: title}) | rest]}
  end

  @doc """
  Reverses the document's entire content recursively.

  Uses `Org.Section.reverse_recursive/1` and `Org.Content.reverse_recursive/1` to reverse sections and contents.

  Example (comments):
      iex> doc = %Org.Document{}
      iex> doc = Org.Document.add_comment(doc, "first")
      iex> doc = Org.Document.add_comment(doc, "second")
      iex> doc = Org.Document.add_comment(doc, "third")
      iex> doc.comments
      ["third", "second", "first"]
      iex> doc = Org.Document.reverse_recursive(doc)
      iex> doc.comments
      ["first", "second", "third"]

  Example (sections):
      iex> doc = %Org.Document{}
      iex> doc = Org.Document.add_subsection(doc, 1, "First")
      iex> doc = Org.Document.add_subsection(doc, 1, "Second")
      iex> doc = Org.Document.add_subsection(doc, 1, "Third")
      iex> for %Org.Section{title: title} <- doc.sections, do: title
      ["Third", "Second", "First"]
      iex> doc = Org.Document.reverse_recursive(doc)
      iex> for %Org.Section{title: title} <- doc.sections, do: title
      ["First", "Second", "Third"]

  Example (contents):
      iex> doc = %Org.Document{}
      iex> doc = Org.Document.prepend_content(doc, %Org.Paragraph{lines: ["first paragraph, first line"]})
      iex> doc = Org.Document.update_content(doc, fn p -> Org.Paragraph.prepend_line(p, "first paragraph, second line") end)
      iex> doc = Org.Document.prepend_content(doc, %Org.Paragraph{lines: ["second paragraph, first line"]})
      iex> doc = Org.Document.update_content(doc, fn p -> Org.Paragraph.prepend_line(p, "second paragraph, second line") end)
      iex> Org.Document.contents(doc)
      [%Org.Paragraph{lines: ["second paragraph, second line", "second paragraph, first line"]},
       %Org.Paragraph{lines: ["first paragraph, second line", "first paragraph, first line"]}]
      iex> doc = Org.Document.reverse_recursive(doc)
      iex> Org.Document.contents(doc)
      [%Org.Paragraph{lines: ["first paragraph, first line", "first paragraph, second line"]},
       %Org.Paragraph{lines: ["second paragraph, first line", "second paragraph, second line"]}]
  """
  def reverse_recursive(doc) do
    %Org.Document{
      doc |
      comments: Enum.reverse(doc.comments),
      sections: Enum.reverse(Enum.map(doc.sections, &Org.Section.reverse_recursive/1)),
      contents: Enum.reverse(Enum.map(doc.contents, &Org.Content.reverse_recursive/1)),
    }
  end

  @doc ~S"""
  Prepend content to the currently deepest section, or toplevel if no sections exist.

  See documentation of `reverse_recursive/1` for a usage example.
  """
  def prepend_content(%Org.Document{sections: []} = doc, content) do
    %Org.Document{doc | contents: [content | doc.contents]}
  end

  def prepend_content(%Org.Document{sections: [current_section | rest]} = doc, content) do
    %Org.Document{doc | sections: [Org.Section.prepend_content(current_section, content) | rest]}
  end


  @doc ~S"""
  Prepend property to the currently deepest section.

  While preserving order is usually not needed for parsing and
  interpreting properties, order is still preserved here to e.g. allow
  re-serialization that preserves line order. This would be desirable
  e.g. since version control is often based on lines, and works better
  if there is less noise in the commit history.

  See prepend_content for usage.
  """
  def prepend_property(%Org.Document{sections: [current_section | rest]} = doc, property) do
    %Org.Document{doc | sections: [Org.Section.prepend_property(current_section, property) | rest]}
  end

  @doc ~S"""
  Update the last prepended content. Yields the content to the given updater.

  See documentation of `reverse_recursive/1` for a usage example.
  """
  def update_content(%Org.Document{sections: [], contents: [current_content | rest]} = doc, updater) do
    %Org.Document{doc | contents: [updater.(current_content) | rest]}
  end

  def update_content(%Org.Document{sections: [current_section | rest]} = doc, updater) do
    %Org.Document{doc | sections: [Org.Section.update_content(current_section, updater) | rest]}
  end
end
