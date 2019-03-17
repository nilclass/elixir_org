defmodule OrgTest do
  use ExUnit.Case
  doctest Org

  @document ~S"""
  #+TITLE: Hello World

  * Hello
  ** World
  | X | Y |
  |---+---|
  | 0 | 4 |
  | 1 | 7 |
  | 2 | 5 |
  | 3 | 6 |
  ** Universe
  Something something...
  * Also
  1
  ** another
  2
  *** thing
      :PROPERTIES:
      :Title:     Goldberg Variations
      :Composer:  J.S. Bach
      :Artist:    Glenn Gould
      :Publisher: Deutsche Grammophon
      :NDisks:    1
      :END:
  3
  **** is nesting
  4
  ***** stuff
  5
  ** at
  6
  *** different
  7
  **** levels
  8
  *** and
  9
  *** next
  10
  *** to
  11
  *** one
  12
  *** another
  13
  #+BEGIN_SRC sql
  SELECT * FROM products;
  #+END_SRC
  """

  # Used by Org.LexerTest and Org.ParserTest
  def example_document do
    @document
  end

end
