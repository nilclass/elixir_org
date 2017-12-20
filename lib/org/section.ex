defmodule Org.Section do
  defstruct title: "", children: [], contents: []

  @moduledoc ~S"""
  Represents a section of a document with a title and possible contents & subsections.

  Example:
      iex> source = "* Hello\nWorld\n** What's up?\nNothing much.\n** How's it going?\nAll fine, whow are you?\n"
      iex> doc = Org.Parser.parse(source)
      iex> section = Org.section(doc, ["Hello"])
      iex> section.contents
      [%Org.Paragraph{lines: ["World"]}]
      iex> length(section.children)
      2
      iex> for child <- section.children, do: child.title
      ["What's up?", "How's it going?"]
  """

  @type t :: %Org.Section{
    title: String.t,
    children: list(Org.Section.t),
    contents: list(Org.Content.t),
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
    }
  end

  def find_by_path(_, []) do
    raise "BUG: can't find section with empty path!"
  end

  def find_by_path([], path) do
    raise "Section not found with remaining path: #{inspect path}"
  end

  def find_by_path([%Org.Section{title: x} = matching_section | _], [x | rest_path]) do
    if length(rest_path) == 0 do
      matching_section
    else
      find_by_path(matching_section.children, rest_path)
    end
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
end
