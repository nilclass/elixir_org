defprotocol Org.Content do
  @moduledoc ~S"""
  Represents a piece of content, such as:
  * `Org.Table`
  * `Org.Paragraph`
  * `Org.CodeBlock`
  """

  @doc "Reverses the content's elements. Used by the parser after building up content in reverse."
  def reverse_recursive(content)
end

# This is just to shut up dialyzer:
defimpl Org.Content, for: [Atom, BitString, Float, Function, Integer, List, Map, PID, Port, Reference, Tuple] do
  def reverse_recursive(content) do
    raise "#{__MODULE__} Not implemented for #{inspect content}"
  end
end
