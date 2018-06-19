defmodule Org.CodeBlock do
  defstruct lang: "", details: "", lines: []

  @type t :: %Org.CodeBlock{
    lang: String.t,
    details: String.t,
    lines: list(String.t),
  }

  @moduledoc ~S"""
  Represents a block of code.

  Example:
      iex> doc = Org.Parser.parse("#+BEGIN_SRC emacs-lisp -n 20\n(message \"Hello World\")\n#+END_SRC")
      iex> doc.contents
      [%Org.CodeBlock{lang: "emacs-lisp", details: "-n 20", lines: ["(message \"Hello World\")"]}]
  """

  @doc "Construct a new code block, with given language details & lines"
  @spec new(String.t, String.t, list(String.t)) :: t
  def new(lang, details, lines \\ []) do
    %Org.CodeBlock{lang: lang, details: details, lines: lines}
  end

  @doc "Prepend a line of code. Used by the parser."
  @spec prepend_line(t, String.t) :: t
  def prepend_line(code_block, line) do
    %Org.CodeBlock{code_block | lines: [line | code_block.lines]}
  end
end

defimpl Org.Content, for: Org.CodeBlock do
  def reverse_recursive(code_block) do
    %Org.CodeBlock{code_block | lines: Enum.reverse(code_block.lines)}
  end
end

