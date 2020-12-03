defmodule Advent2020.Grid do
  @moduledoc """
  A `Grid` is a 2D array of single-character strings. Neither Elixir
  nor the Erlang VM have any notion of a standard O(1) access array (!)
  so we use a tuple of tuples to emulate the same. The access
  characteristics are about the same as arrays in other languages, but
  updates can be really slow since the tuple of tuples needs to be
  reconstructed entirely on every change. Thankfully, for our use-case
  we are just creating these things once and not changing them.
  """

  @doc """
  Given a list of strings (like from a file), create a Grid.
  """
  def from_list_of_strings(list) do
    list
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  @doc """
  Access the value at a particular coordinate in the Grid.
  """
  def get(grid, x, y) do
    y_max = tuple_size(grid) - 1
    if y > y_max do
      {:error, "out of bounds"}
    else
      line = elem(grid, y)
      line_length = tuple_size(line)
      actual_x = rem(x, line_length)
      {:ok, elem(line, actual_x)}
    end
  end

  @doc """
  Trace along a slope in a grid (optionally providing starting
  coordinates), and return a list that represents the 1D projection
  of what was found along that slope.
  """
  def collect_in_slope(grid, dx, dy, x \\ 0, y \\ 0, proj \\ []) do
    case get(grid, x, y) do
      {:ok, value} -> collect_in_slope(grid, dx, dy, x + dx, y + dy, [ value | proj ])
      {:error, _} -> Enum.reverse(proj)
    end
  end
end
