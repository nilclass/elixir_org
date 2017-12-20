
defmodule Org.Table.Row do
  defstruct cells: []
end

defmodule Org.Table.Separator do
  defstruct []
end

defmodule Org.Table do
  defstruct rows: []

  @moduledoc ~S"""
  Represents a table.

  Example:
      iex> source = "| *Foo* | *Bar* |\n|-------+-------|\n|   123 |  456  |"
      iex> doc = Org.Parser.parse(source)
      iex> [table] = Org.tables(doc)
      iex> Enum.at(table.rows, 0)
      %Org.Table.Row{cells: ["*Foo*", "*Bar*"]}
      iex> Enum.at(table.rows, 1)
      %Org.Table.Separator{}
      iex> Enum.at(table.rows, 2)
      %Org.Table.Row{cells: ["123", "456"]}
  """

  @doc """
  Constructs a new table, with given initial rows.

  The rows can either be Org.Table.Row / Org.Table.Separator structs or
  will be interpreted from a list of cell contents.

  Creating a table from plain cell contents:
      iex> table = Org.Table.new([["foo", "bar"]])
      iex> table.rows
      [%Org.Table.Row{cells: ["foo", "bar"]}]

  Creating a table from row structures:
      iex> table = Org.Table.new([%Org.Table.Row{cells: ["foo", "bar"]}])
      iex> table.rows
      [%Org.Table.Row{cells: ["foo", "bar"]}]

  Creating a table from a mixture of structures and cell contents:
      iex> table = Org.Table.new([["foo"], %Org.Table.Separator{}, ["bar"]])
      iex> table.rows
      [%Org.Table.Row{cells: ["foo"]}, %Org.Table.Separator{}, %Org.Table.Row{cells: ["bar"]}]
  """
  def new(rows) do
    %Org.Table{rows: Enum.map(rows, &cast_row/1)}
  end

  @doc """
  Prepends a row to the table. The row will be cast the same way as when passed to `new/1`.

  This function is used by the parser, which builds up documents in reverse and then finally
  calls Org.Content.reverse_recursive/1 to yield the original order.
  """
  def prepend_row(table, row) do
    %Org.Table{table | rows: [cast_row(row) | table.rows]}
  end

  @doc """
  Returns a table with the given number of leading rows omitted.

  Example:
      iex> table = Org.Table.new([["X", "Y"], ["7", "4"], ["3", "8"], ["15", "24"]])
      iex> Org.Table.skip_rows(table, 1)
      %Org.Table{rows: [%Org.Table.Row{cells: ["7", "4"]}, %Org.Table.Row{cells: ["3", "8"]}, %Org.Table.Row{cells: ["15", "24"]}]}
  """
  def skip_rows(table, 0) do
    table
  end

  def skip_rows(table, n) do
    skip_rows(%Org.Table{table | rows: tl(table.rows)}, n - 1)
  end

  @doc """
  Returns a list of rows with cells named according to given keys.

  Example:
      iex> table = Org.Table.new([["Width", "20"], ["Height", "40"]])
      iex> Org.Table.extract_rows(table, [:parameter_name, :value])
      [%{parameter_name: "Width", value: "20"}, %{parameter_name: "Height", value: "40"}]
  """
  def extract_rows(table, keys) do
    for %Org.Table.Row{cells: cells} <- table.rows do
      keys
      |> Enum.zip(cells)
      |> Enum.into(%{})
    end
  end

  defp cast_row(%{__struct__: type} = row) when type in [Org.Table.Row, Org.Table.Separator] do
    row
  end

  defp cast_row(cells) do
    if String.match?(hd(cells), ~r/^\-+/) do
      %Org.Table.Separator{}
    else
      %Org.Table.Row{cells: cells}
    end
  end
end

defimpl Org.Content, for: Org.Table do
  def reverse_recursive(table) do
    %Org.Table{table | rows: Enum.reverse(table.rows)}
  end
end
