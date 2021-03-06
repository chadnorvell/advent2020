defmodule Advent2020.BoardingPass do
  alias Advent2020.Utilities

  @max_row 127
  @max_col 7

  @row Utilities.list_to_bsp(for(x <- 0..@max_row, do: x), :f, :b)
  @col Utilities.list_to_bsp(for x <- 0..@max_col, do: x)

  @doc """
  Given a boarding pass seat code, return the row and column of the
  seat.
  """
  def get_seat(s) do
    {row_codes, col_codes} =
      s
      |> String.downcase()
      |> String.graphemes()
      |> Enum.split(7)

    {get_leaf(row_codes, @row), get_leaf(col_codes, @col)}
  end

  defp get_leaf([current | rest], tree) do
    case rest do
      [] -> tree[String.to_atom(current)]
      _ -> get_leaf(rest, tree[String.to_atom(current)])
    end
  end

  @doc """
  Return the seat ID given a row and seat.
  """
  def id({row, col}), do: row * 8 + col

  @doc """
  Return the row and seat given the seat ID.
  """
  def from_id(id), do: {div(id, 8), rem(id, 8)}

  @doc """
  Find any empty seats based on boarding pass input.
  """
  def find_empty_seats(seats) do
    all_seats =
      MapSet.new(for row <- 0..@max_row, col <- 0..@max_col, do: {row, col})

    seats = MapSet.new(seats)

    MapSet.difference(all_seats, seats)
    |> MapSet.to_list()
  end

  @doc """
  Find any empty seats given a list of occupied seat IDs.
  """
  def find_empty_seats_by_id(seat_ids) do
    all_seat_ids =
      MapSet.new(for row <- 0..@max_row, col <- 0..@max_col, do: id({row, col}))

    seat_ids = MapSet.new(seat_ids)

    MapSet.difference(all_seat_ids, seat_ids)
    |> MapSet.to_list()
  end

  def group_by_row([current | rest], acc \\ %{}) do
    case rest do
      [] ->
        acc

      _ ->
        group_by_row(
          rest,
          Map.update(acc, elem(current, 0), [elem(current, 1)], fn xs ->
            [elem(current, 1) | xs]
          end)
        )
    end
  end
end
