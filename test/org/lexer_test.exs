defmodule Org.LexerTest do
  use ExUnit.Case
  doctest Org.Lexer

  require OrgTestHelper

  describe "lex document" do
    setup do
      tokens = Org.Lexer.lex(OrgTest.example_document)
      {:ok, %{tokens: tokens}}
    end

    OrgTestHelper.test_tokens [
      {:comment, "+TITLE: Hello World"},
      {:empty_line},
      {:section_title, 1, "Hello"},
      {:section_title, 2, "World"},
      {:table_row, ["X", "Y"]},
      {:table_row, ["---+---"]},
      {:table_row, ["0", "4"]},
      {:table_row, ["1", "7"]},
      {:table_row, ["2", "5"]},
      {:table_row, ["3", "6"]},
      {:section_title, 2, "Universe"},
      {:text, "Something something..."},
      {:section_title, 1, "Also"},
      {:text, "1"},
      {:section_title, 2, "another"},
      {:text, "2"},
      {:section_title, 3, "thing"},
      {:begin_drawer, "PROPERTIES"},
      {:property, "Title", "Goldberg Variations"},
      {:property, "Composer", "J.S. Bach"},
      {:property, "Artist", "Glenn Gould"},
      {:property, "Publisher", "Deutsche Grammophon"},
      {:property, "NDisks", "1"},
      {:end_drawer},
      {:text, "3"},
      {:section_title, 4, "is nesting"},
      {:text, "4"},
      {:section_title, 5, "stuff"},
      {:text, "5"},
      {:section_title, 2, "at"},
      {:text, "6"},
      {:section_title, 3, "different"},
      {:text, "7"},
      {:section_title, 4, "levels"},
      {:text, "8"},
      {:section_title, 3, "and"},
      {:text, "9"},
      {:section_title, 3, "next"},
      {:text, "10"},
      {:section_title, 3, "to"},
      {:text, "11"},
      {:section_title, 3, "one"},
      {:text, "12"},
      {:section_title, 3, "another"},
      {:text, "13"},
      {:begin_src, "sql", ""},
      {:raw_line, "SELECT * FROM products;"},
      {:end_src},
      {:empty_line}
    ]
  end
end
