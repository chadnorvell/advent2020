defmodule Advent2020.Xmas do
  import Advent2020.Utilities, only: [two_sum: 2]

  @doc """
  Given a list of numbers and a window size, shift the window until the value
  directly after the window is not a sum of two numbers within the window.
  """
  def find_not_sum([], _), do: nil

  def find_not_sum([_ | rest] = nums, window) do
    if Enum.count(nums) >= 25 do
      [this_num | nums_to_sum] = Enum.take(nums, 26) |> Enum.reverse()

      case two_sum(nums_to_sum, this_num) do
        [_, _] -> find_not_sum(rest, window)
        nil -> this_num
      end
    else
      nil
    end
  end

  @doc """
  In a list of numbers, find a contiguous range that adds up to the provided
  sum. If found, return the slice.
  """
  def find_sum_in_contiguous_range(nums, sum, offset \\ 1)
  def find_sum_in_contiguous_range([], _, _), do: nil

  def find_sum_in_contiguous_range([_ | rest] = nums, sum, offset) do
    slice = Enum.slice(nums, 0, offset)
    slice_sum = Enum.sum(slice)

    cond do
      slice_sum == sum ->
        slice

      slice_sum < sum ->
        find_sum_in_contiguous_range(nums, sum, offset + 1)

      slice_sum > sum ->
        find_sum_in_contiguous_range(rest, sum, offset - 1)
    end
  end
end
