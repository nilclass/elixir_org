defmodule OrgTestHelper do
  defmacro test_tokens(expected) do
    for {token, index} <- Enum.with_index(expected) do
      quote do
        test "Token #{unquote(index)} equals #{inspect(unquote(token))}", %{tokens: tokens} do
          assert Enum.at(tokens, unquote(index)) == unquote(token)
        end
      end
    end
    ++
    [quote do
      test "There are #{unquote(length(expected))} tokens", %{tokens: tokens} do
        assert length(tokens) == unquote(length(expected))
      end
    end]
  end

  defmacro test_section_text_contents(expected) do
    for {path, text_content} <- expected do
      quote do
        test "Section at #{inspect(unquote(path))} has content #{inspect(unquote(text_content))}", %{doc: doc} do
          assert Org.Section.contents(Org.section(doc, unquote(path))) == [%Org.Paragraph{lines: unquote(text_content)}]
        end
      end
    end
  end
end

ExUnit.start()
