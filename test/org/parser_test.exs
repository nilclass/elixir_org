defmodule Org.ParserTest do
  use ExUnit.Case
  doctest Org.Parser

  require OrgTestHelper

  describe "parse document" do
    setup do
      doc = Org.Parser.parse(OrgTest.example_document)
      {:ok, %{doc: doc}}
    end

    OrgTestHelper.test_section_text_contents([
      {["Also"], ["1"]},
      {["Also", "another"], ["2"]},
      {["Also", "another", "thing"], ["3"]},
      {["Also", "another", "thing", "is nesting"], ["4"]},
      {["Also", "another", "thing", "is nesting", "stuff"], ["5"]},
      {["Also", "at"], ["6"]},
      {["Also", "at", "different"], ["7"]},
      {["Also", "at", "different", "levels"], ["8"]},
      {["Also", "at", "and"], ["9"]},
      {["Also", "at", "next"], ["10"]},
      {["Also", "at", "to"], ["11"]},
      {["Also", "at", "one"], ["12"]},
    ])

    test "section with paragraph and code", %{doc: doc} do
      assert Org.Section.contents(Org.section(doc, ["Also", "at", "another"])) == [
        %Org.Paragraph{lines: ["13"]},
        %Org.CodeBlock{lang: "sql", details: "", lines: ["SELECT * FROM products;"]},
      ]
    end
  end
end
