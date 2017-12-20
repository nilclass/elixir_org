defmodule Org.Lexer do
  defstruct tokens: []

  @type token :: (
    {:comment, String.t} |
    {:section_title, integer, String.t} |
    {:table_row, list(String.t)} |
    {:empty_line} |
    {:text, String.t}
  )

  @type t :: %Org.Lexer{tokens: list(token)}

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

  @comment_re       ~r/^#(.+)$/
  @section_title_re ~r/^(\*+) (.+)$/
  @empty_line_re    ~r/^\s*$/
  @table_row_re     ~r/^\s*(?:\|[^|]*)+\|\s*$/

  defp lex_line(line, lexer) do
    token = cond do
      match = Regex.run(@comment_re, line) ->
        [_, text] = match
        {:comment, text}
      match = Regex.run(@section_title_re, line) ->
        [_, nesting, title] = match
        {:section_title, String.length(nesting), title}
      Regex.run(@empty_line_re, line) ->
        {:empty_line}
      Regex.run(@table_row_re, line) ->
        cells = ~r/\|(?<cell>[^|]+)/
        |> Regex.scan(line, capture: :all_names)
        |> List.flatten
        |> Enum.map(&String.trim/1)
        {:table_row, cells}
      true ->
        {:text, line}
    end

    %Org.Lexer{lexer | tokens: [token | lexer.tokens]}
  end
end
