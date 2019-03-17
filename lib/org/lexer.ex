defmodule Org.Lexer do
  defstruct tokens: [], mode: :normal

  @type token :: (
    {:comment, String.t} |
    {:section_title, integer, String.t} |
    {:table_row, list(String.t)} |
    {:empty_line} |
    {:text, String.t}
  )

  @type t :: %Org.Lexer{
    tokens: list(token),
    mode: :normal | :raw | :property
  }

  @moduledoc ~S"""
  Splits an org-document into tokens.

  For many simple tasks, using the lexer is enough, and a full-fledged `Org.Document` is not needed.

  Usage example:
      iex> source = "#+TITLE: Greetings\n\n* Hello\n** World\n** Universe\n* Goodbye\n"
      iex> Org.Lexer.lex(source)
      [{:comment, "+TITLE: Greetings"},
       {:empty_line},
       {:section_title, 1, "Hello"},
       {:section_title, 2, "World"},
       {:section_title, 2, "Universe"},
       {:section_title, 1, "Goodbye"},
       {:empty_line}]
  """

  @spec lex(String.t) :: list(token)
  def lex(text) do
    text
    |> String.split("\n")
    |> lex_lines
    |> Map.get(:tokens)
    |> Enum.reverse
  end

  defp lex_lines(lexer \\ %Org.Lexer{}, lines)

  defp lex_lines(lexer, []) do
    lexer
  end

  defp lex_lines(lexer, [line | rest]) do
    line
    |> lex_line(lexer)
    |> lex_lines(rest)
  end

  @begin_src_re     ~r/^#\+BEGIN_SRC(?:\s+([^\s]*)\s?(.*)|)$/
  @end_src_re       ~r/^#\+END_SRC$/
  @comment_re       ~r/^#(.+)$/
  @section_title_re ~r/^(\*+) (.+)$/
  @empty_line_re    ~r/^\s*$/
  @table_row_re     ~r/^\s*(?:\|[^|]*)+\|\s*$/
  @begin_props_re   ~r/^\s*\:PROPERTIES\:$/
  @property_re      ~r/^\s*\:([A-Za-z]+)\:\s*(.+)$/
  @end_drawer_re    ~r/^\s*\:END\:$/

  defp lex_line(line, %Org.Lexer{mode: :normal} = lexer) do
    cond do
      match = Regex.run(@begin_src_re, line) ->
        [_, lang, details] = match
        append_token(lexer, {:begin_src, lang, details}) |> set_mode(:raw)
      match = Regex.run(@comment_re, line) ->
        [_, text] = match
        append_token(lexer, {:comment, text})
      match = Regex.run(@section_title_re, line) ->
        [_, nesting, title] = match
        append_token(lexer, {:section_title, String.length(nesting), title})
      Regex.run(@empty_line_re, line) ->
        append_token(lexer, {:empty_line})
      Regex.run(@table_row_re, line) ->
        cells = ~r/\|(?<cell>[^|]+)/
        |> Regex.scan(line, capture: :all_names)
        |> List.flatten
        |> Enum.map(&String.trim/1)
        append_token(lexer, {:table_row, cells})
      Regex.run(@begin_props_re, line) ->
        append_token(lexer, {:begin_drawer, "PROPERTIES"}) |> set_mode(:property)
      true ->
        append_token(lexer, {:text, line})
    end
  end

  defp lex_line(line, %Org.Lexer{mode: :raw} = lexer) do
    if Regex.run(@end_src_re, line) do
      append_token(lexer, {:end_src}) |> set_mode(:normal)
    else
      append_token(lexer, {:raw_line, line})
    end
  end

  defp lex_line(line, %Org.Lexer{mode: :property} = lexer) do
    cond do
      Regex.run(@end_drawer_re, line) ->
        append_token(lexer, {:end_drawer}) |> set_mode(:normal)
      match = Regex.run(@property_re, line) ->
        [_, key, value] = match
        append_token(lexer, {:property, key, value})
    end
  end

  defp append_token(%Org.Lexer{} = lexer, token) do
    %Org.Lexer{lexer | tokens: [token | lexer.tokens]}
  end

  defp set_mode(%Org.Lexer{} = lexer, mode) do
    %Org.Lexer{lexer | mode: mode}
  end
end
