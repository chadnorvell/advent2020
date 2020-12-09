defmodule Advent2020.Expenses do
  import Advent2020.Utilities, only: [two_sum: 4]

  def expense_report(values, sum, skip \\ nil, skip_times \\ 1) do
    case two_sum(values, sum, skip, skip_times) do
      nil -> nil
      [x, y] -> x * y
    end
  end
end
