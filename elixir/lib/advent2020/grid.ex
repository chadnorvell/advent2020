defmodule Advent2020.Grid do
  @moduledoc """
  A `Grid` is a 2D array of single-character strings. Neither Elixir
  nor the Erlang VM have any notion of a standard O(1) access array (!)
  so we use a tuple of tuples to emulate the same. The access
  characteristics are about the same as arrays in other languages, but
  updates can be really slow since the tuple of tuples needs to be
  reconstructed entirely on every change. Oh well!
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
    x_max = tuple_size(elem(grid, 0)) - 1
    y_max = tuple_size(grid) - 1

    if x >= 0 and x <= x_max and (y >= 0 and y <= y_max) do
      line = elem(grid, y)
      {:ok, elem(line, x)}
    else
      {:error, "out of bounds"}
    end
  end

  @doc """
  Access the value at a particular coordinate in the Grid, extending the grid
  endlessly in the X direction.
  """
  def get_extend_x(grid, x, y) do
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
  Count the number of the provided character in the 8 spaces immediately
  adjacent to the specified element.
  """
  def count_around(grid, x, y, char, invisible, dx \\ -1, dy \\ -1, count \\ 0) do
    new_count =
      if dx == 0 and dy == 0 do
        count
      else
        case get(grid, x + dx, y + dy) do
          {:error, _} -> count
          {:ok, element} -> if element == char, do: count + 1, else: count
        end
      end

    case advance_within_subgrid(dx, dy, -1, -1, 1, 1) do
      {-1, -1} -> new_count
      {dx, dy} -> count_around(grid, x, y, char, invisible, dx, dy, new_count)
    end
  end

  defp advance_within_subgrid(x, y, x_min, y_min, x_max, y_max) do
    cond do
      x < x_max ->
        {x + 1, y}

      x >= x_max ->
        cond do
          y < y_max -> {x_min, y + 1}
          y >= y_max -> {x_min, y_min}
        end
    end
  end

  @doc """
  From the provided element, look in each of the 8 directions and return the
  number of times the provided character is visible. Invisible characters are
  ignored. Other characters block line-of-sight.
  """
  def count_los(grid, x, y, char, invisible) do
    [{-1, -1}, {0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}]
    |> Enum.map(fn {dx, dy} ->
      collect_in_slope(grid, dx, dy, x, y)
      # Remove invisible elements
      |> Enum.filter(fn element -> !Enum.member?(invisible, element) end)
      # Examine the first visible element
      |> (fn xs ->
            case xs do
              [head | _] -> head == char
              [] -> false
            end
          end).()
    end)
    |> Enum.count(fn element -> element == true end)
  end

  @doc """
  Count the total number of a particular character in the grid.
  """
  def count_total(grid, char) do
    grid
    |> Tuple.to_list()
    |> Enum.map(fn t ->
      Tuple.to_list(t) |> Enum.count(fn x -> x == char end)
    end)
    |> Enum.sum()
  end

  def update(grid, x, y, new_val) do
    new_row = :erlang.setelement(x + 1, elem(grid, y), new_val)
    :erlang.setelement(y + 1, grid, new_row)
  end

  @doc """
  Trace along a slope in a grid (optionally providing starting
  coordinates), and return a list that represents the 1D projection
  of what was found along that slope.
  """
  def collect_in_slope(grid, dx, dy, x \\ 0, y \\ 0, proj \\ []) do
    case get(grid, x + dx, y + dy) do
      {:ok, value} ->
        collect_in_slope(grid, dx, dy, x + dx, y + dy, [value | proj])

      {:error, _} ->
        Enum.reverse(proj)
    end
  end

  @doc """
  Trace along a slope in a grid (optionally providing starting
  coordinates), and return a list that represents the 1D projection
  of what was found along that slope. This version extends the grid
  into the X direction infinitely.
  """
  def collect_in_slope_extend_x(grid, dx, dy, x \\ 0, y \\ 0, proj \\ []) do
    case get_extend_x(grid, x, y) do
      {:ok, value} ->
        collect_in_slope_extend_x(grid, dx, dy, x + dx, y + dy, [value | proj])

      {:error, _} ->
        Enum.reverse(proj)
    end
  end

  def pretty_print(grid) do
    grid
    |> Tuple.to_list()
    |> Enum.map(fn row -> Tuple.to_list(row) |> Enum.join() end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
