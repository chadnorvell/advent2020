defmodule Advent2020 do
  alias Advent2020.Expenses
  alias Advent2020.Grid
  alias Advent2020.Passwords
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
      Passwords.check_against_policy_old(policy, password) end)
    |> Enum.count(fn result -> result == true end)
  end

  def day2_2() do
    Utilities.file_to_list("./data/day2_1.txt")
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.map(fn [policy | [password | []]] ->
      Passwords.check_against_policy_new(policy, password) end)
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
end
