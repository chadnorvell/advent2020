defmodule Advent2020 do
  alias Advent2020.BoardingPass
  alias Advent2020.Expenses
  alias Advent2020.Grid
  alias Advent2020.Passport
  alias Advent2020.Password
  alias Advent2020.Utilities

  def day1_1() do
    Utilities.file_to_list("./data/day1_1.txt")
    |> Enum.map(fn s -> String.to_integer s end)
    |> Expenses.expense_report(2020)
  end

  def day1_2() do
    # For each value in the list, find the complement, then try to find
    # two more numbers that sum to that complement. This bumps us to
    # O(n ^ 2).

    Utilities.file_to_list("./data/day1_1.txt")
    |> Enum.map(fn s -> String.to_integer s end)
    |> (fn values -> day1_2_loop(values, values, 2020) end).()
  end

  defp day1_2_loop(all_values, remaining_values, sum) do
    # Pop off the first remaining value in the list on each run
    [ value | rest ] = remaining_values

    # This complement is the sum that needs to be produced by two
    # other values in the original list.
    complement = sum - value

    case Expenses.expense_report(all_values, complement, value) do
      # We did not find two more values that produce the desired sum
      nil ->
        case rest do
          [] -> nil  # We've gone through the whole list and didn't find a match
          _ -> day1_2_loop(all_values, rest, sum)  # There are more values; keep trying
        end

      # We found a match!
      pair_product -> pair_product * value
    end
  end

  def day2_1() do
    Utilities.file_to_list("./data/day2_1.txt")
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.map(fn [policy | [password | []]] ->
      Password.check_against_policy_old(policy, password) end)
    |> Enum.count(fn result -> result == true end)
  end

  def day2_2() do
    Utilities.file_to_list("./data/day2_1.txt")
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.map(fn [policy | [password | []]] ->
      Password.check_against_policy_new(policy, password) end)
    |> Enum.count(fn result -> result == true end)
  end

  def day3_1() do
    Utilities.file_to_list("./data/day3_1.txt")
    |> Grid.from_list_of_strings()
    |> Grid.collect_in_slope(3, 1)
    |> Enum.count(fn element -> element == "#" end)
  end

  def day3_2() do
    grid = Utilities.file_to_list("./data/day3_1.txt")
    |> Grid.from_list_of_strings()

    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(fn {dx, dy} ->
      Grid.collect_in_slope(grid, dx, dy)
      |> Enum.count(fn element -> element == "#" end)
    end)
    |> Enum.reduce(fn x, acc -> acc * x end)
  end

  def day4_1() do
    Utilities.file_to_list("./data/day4_1.txt", trim: false)
    |> Utilities.file_lines_to_kv_pairs(":", [" ", "\n"], "")
    |> Enum.map(fn data -> Passport.ok?(data) end)
    |> Enum.count(fn result -> result == true end)
  end

  def day4_2() do
    Utilities.file_to_list("./data/day4_1.txt", trim: false)
    |> Utilities.file_lines_to_kv_pairs(":", [" ", "\n"], "")
    |> Enum.filter(fn data -> Passport.ok? data end)
    |> Enum.map(fn data -> struct(Passport, data) |> Passport.validate() end)
    |> Enum.count(fn result -> result != :error end)
  end

  def day5_1() do
    Utilities.file_to_list("./data/day5_1.txt")
    |> Enum.map(fn pass -> BoardingPass.get_seat(pass) end)
    |> Enum.map(fn pass -> BoardingPass.id(pass) end)
    |> Enum.max()
  end

  def day5_2() do
    Utilities.file_to_list("./data/day5_1.txt")
    |> Enum.map(fn pass -> BoardingPass.get_seat(pass) end)
    |> BoardingPass.find_empty_seats()
    |> BoardingPass.group_by_row()
    |> Enum.map(fn {k, v} -> {k, v} end)
    # If seat IDs +/- from ours are occupied, there must only be
    # a single empty seat in the row.
    |> Enum.filter(fn {_, cols} -> Enum.count(cols) == 1 end)
    |> List.first()
    |> (fn {row, [ col | []]} -> {row, col} end).()
    |> BoardingPass.id()
  end

  # This is based on the recognition that the boarding pass data is
  # really just a 10-bit integer (7 bits for the row and 3 bits for
  # the seat). Converting that integer to decimal gives you the seat
  # ID, and you can carry on from there. The BSP stuff is a bit of a
  # red herring that leads you to implementing your own binary-to-
  # decimal parser. Fun, but not necessary to solve the problem.
  def day5_1_smarter(), do: day5_smart_processing() |> Enum.max()

  def day5_2_smarter() do
    day5_smart_processing()
    |> BoardingPass.find_empty_seats_by_id()
    |> Enum.sort(&(&1 < &2))
    # If seat IDs +/- from ours are occupied, there must only be
    # a single empty seat in the row. That would manifest as an
    # empty seat N where seats N-1 and N+1 are not present in the
    # set of empty seats.
    |> day5_2_smart_loop()
  end

  defp day5_smart_processing() do
    zeros = ~r/(F|L)/
    ones = ~r/(B|R)/
    regex_replace = fn string, regex, replacement ->
      Regex.replace(regex, string, replacement)
    end

    Utilities.file_to_list("./data/day5_1.txt")
    |> Enum.map(fn s -> s
      |> regex_replace.(zeros, "0")
      |> regex_replace.(ones, "1")
      |> Integer.parse(2)
      |> elem(0)
    end)
  end

  defp day5_2_smart_loop(list) do
    case list do
      [ x, y, z | rest] ->
        if (y - x != 1) and (z - y != 1) do
          y
        else
          case rest do
            [] -> nil
            _ -> day5_2_smart_loop([y, z | rest])
          end
        end
    end
  end

  def day6_1() do
    Utilities.file_to_list("./data/day6_1.txt", trim: false)
    |> Utilities.file_lines_to_char_sets("", fn current, new ->
      current = current || MapSet.new()
      MapSet.union(current, new)
    end)
    |> Enum.map(fn set -> Enum.count(set) end)
    |> Enum.reduce(fn count, sum -> sum + count end)
  end

  def day6_2() do
    Utilities.file_to_list("./data/day6_1.txt", trim: false)
    |> Utilities.file_lines_to_char_sets("", fn current, new ->
      current = current || MapSet.new(
        Enum.to_list(?a..?z) |> Enum.map(fn(n) -> <<n>> end)
      )
      MapSet.intersection(current, new)
    end)
    |> Enum.map(fn set -> Enum.count(set) end)
    |> Enum.reduce(fn count, sum -> sum + count end)
  end
end
