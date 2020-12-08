defmodule Advent2020.Expenses do
  @doc """
  Given a set of numbers and a specified sum, find the two values in the
  list that add up to the sum, and return their product, if they exist.
  Otherwise return nil. You can provide a single value to be skipped.

  Runs in O(n) time and space!
  """
  def expense_report(values, sum, skip \\ nil, skip_times \\ 1) do
    product_if_sum(MapSet.new(), values, sum, skip, skip_times)
  end

  defp product_if_sum(cache, values, sum, skip, skip_times) do
    # We'll examine the first entry in the list of values.
    [value | rest] = values

    # If the current value is one that we specified to ignore, short-
    # circuit this iteration and move on to the next.
    if value == skip && skip_times > 0 do
      product_if_sum(cache, rest, sum, skip, skip_times - 1)
    end

    # The value that needs to added to that first entry to produce the sum.
    complement = sum - value

    case MapSet.member?(cache, complement) do
      # If the complement is present in the cache, then we've seen it
      # before, therefore it is definitely in the list of values.
      true ->
        value * complement

      # If not, cache this value to indicate we've seen it, and
      # continue through the list of values.
      false ->
        case rest do
          # If there are no more values left, we're done, and there are no
          # two values in the original list that produce the sum.
          [] ->
            nil

          _ ->
            MapSet.put(cache, value)
            |> product_if_sum(rest, sum, skip, skip_times)
        end
    end
  end
end
