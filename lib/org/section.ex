defmodule Org.Section do
  defstruct title: "", children: [], contents: [], properties: []

  @moduledoc ~S"""
  Represents a section of a document with a title and possible contents & subsections.

  Example:
      iex> source = "* Hello\nWorld\n** What's up?\n   :PROPERTIES:\n   :Register: non-formal\n   :Intent: inquisitive\n   :END:\nNothing much.\n** How's it going?\nAll fine, whow are you?\n"
      iex> doc = Org.Parser.parse(source)
      iex> section = Org.section(doc, ["Hello"])
      iex> section.contents
      [%Org.Paragraph{lines: ["World"]}]
      iex> length(section.children)
      2
      iex> for child <- section.children, do: child.title
      ["What's up?", "How's it going?"]
      iex> subsection_with_props = Org.section(doc, ["Hello", "What's up?"])
      iex> subsection_with_props.properties
      [Register: "non-formal", Intent: "inquisitive"]
  """

  @type t :: %Org.Section{
    title: String.t,
    children: list(Org.Section.t),
    contents: list(Org.Content.t),
    properties: list(Keyword.t),
  }

  def add_nested(parent, 1, child) do
    %Org.Section{parent | children: [child | parent.children]}
  end

  def add_nested(parent, level, child) do
    {first, rest} = case parent.children do
                      [first | rest] -> {first, rest}
                      [] -> {%Org.Section{}, []}
                    end
    %Org.Section{parent | children: [add_nested(first || %Org.Section{}, level - 1, child) | rest]}
  end

  def reverse_recursive(section) do
    %Org.Section{
      section |
      children: Enum.reverse(Enum.map(section.children, &reverse_recursive/1)),
      contents: Enum.reverse(Enum.map(section.contents, &Org.Content.reverse_recursive/1)),
      properties: Enum.reverse(section.properties),
    }
  end

  def find_by_path(_, []) do
    raise "BUG: can't find section with empty path!"
  end

  def find_by_path([], path) do
    raise "Section not found with remaining path: #{inspect path}"
  end

  def find_by_path([%Org.Section{title: title} = matching_section | _], [title]) do
    matching_section
  end

  def find_by_path([%Org.Section{title: title} = matching_section | _], [title | rest_path]) do
    find_by_path(matching_section.children, rest_path)
  end

  def find_by_path([_ | rest], path) do
    find_by_path(rest, path)
  end

  def contents(%Org.Section{contents: contents}) do
    contents
  end

  @doc "Adds content to the last prepended section"
  def prepend_content(%Org.Section{children: []} = section, content) do
    %Org.Section{section | contents: [content | section.contents]}
  end

  def prepend_content(%Org.Section{children: [current_child | children]} = section, content) do
    %Org.Section{section | children: [prepend_content(current_child, content) | children]}
  end

  def update_content(%Org.Section{children: [], contents: [current_content | rest]} = section, updater) do
    %Org.Section{section | contents: [updater.(current_content) | rest]}
  end

  def update_content(%Org.Section{children: [current_section | rest]} = section, updater) do
    %Org.Section{section | children: [update_content(current_section, updater) | rest]}
  end

  @doc "Adds property to the last prepended section"
  def prepend_property(%Org.Section{children: []} = section, property) do
    %Org.Section{section | properties: [property | section.properties]}
  end

  def prepend_property(%Org.Section{children: [current_child | children]} = section, property) do
    %Org.Section{section | children: [prepend_property(current_child, property) | children]}
  end
end
