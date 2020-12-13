defmodule Advent2020.Utilities do
  @doc """
  Given a file with desired values on each line, return a list of
  those values.
  """
  def file_to_list(file_name, opts \\ [trim: true]) do
    File.read!(file_name)
    |> String.split("\n", trim: opts[:trim])
  end

  @doc """
  Decode a string containing key-value pairs into a map, or insert the
  pairs into a provided map.
  """
  def decode_kv_pairs(s, kv_delimiter, pair_delimiters, map \\ %{}) do
    s
    |> String.split(pair_delimiters)
    |> Enum.map(fn pair -> String.split(pair, kv_delimiter) end)
    |> Enum.map(fn pair -> List.to_tuple(pair) end)
    |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(%{})
    |> Map.merge(map)
  end

  @doc """
  Convert a list of strings (i.e. from a file) that contain groups of
  key-value pairs into a list of maps.
  """
  def file_lines_to_kv_pairs(
        lines,
        kv_delimiter,
        pair_delimiters,
        group_delimiter,
        current_group \\ %{},
        groups \\ []
      ) do
    case lines do
      # We're done.
      [] ->
        groups

      # We're not done; process the next line.
      [current_line | rest] ->
        case current_line do
          # This line is a separator between groups.
          # So the current group is finished and we will start a new
          # one on the next iteration.
          ^group_delimiter ->
            file_lines_to_kv_pairs(
              rest,
              kv_delimiter,
              pair_delimiters,
              group_delimiter,
              %{},
              [current_group | groups]
            )

          # This line starts or adds to a group.
          line_with_kv ->
            file_lines_to_kv_pairs(
              rest,
              kv_delimiter,
              pair_delimiters,
              group_delimiter,
              decode_kv_pairs(
                line_with_kv,
                kv_delimiter,
                pair_delimiters,
                current_group
              ),
              groups
            )
        end
    end
  end

  @doc """
  Break a string down into its characters and return them as a MapSet.
  """
  def string_to_char_mapset(s) do
    s
    |> String.graphemes()
    |> MapSet.new()
  end

  @doc """
  Convert a list of strings (i.e. from a file) that contain groups of
  characters into a list of MapSets of the characters in each group.
  """
  def file_lines_to_char_sets(
        lines,
        group_delimiter,
        mapset_merge_fn,
        current_group \\ nil,
        groups \\ []
      ) do
    case lines do
      # We're done.
      [] ->
        groups

      # We're not done; process the next line.
      [current_line | rest] ->
        case current_line do
          # This line is a separator between groups.
          # So the current group is finished and we will start a new
          # one on the next iteration.
          ^group_delimiter ->
            file_lines_to_char_sets(
              rest,
              group_delimiter,
              mapset_merge_fn,
              nil,
              [current_group | groups]
            )

          # This line starts or adds to a group.
          line_with_chars ->
            file_lines_to_char_sets(
              rest,
              group_delimiter,
              mapset_merge_fn,
              mapset_merge_fn.(
                current_group,
                string_to_char_mapset(line_with_chars)
              ),
              groups
            )
        end
    end
  end

  @doc """
  Return the logical xor of two boolean values.
  """
  def xor(bool1, bool2) do
    bool1 != bool2
  end

  @doc """
  Use binary space partitioning to produce a binary tree from a
  provided ordered enumeration. I believe this is O(N) (for each
  level of depth of the resulting tree).
  """
  def list_to_bsp(list, lname \\ :l, rname \\ :r) do
    case split_list(list) do
      [[left | []], [right | []]] ->
        Map.new([
          {lname, left},
          {rname, right}
        ])

      [[_ | _] = left, [_ | _] = right] ->
        Map.new([
          {lname, list_to_bsp(left, lname, rname)},
          {rname, list_to_bsp(right, lname, rname)}
        ])
    end
  end

  defp split_list(list), do: Enum.chunk_every(list, div(Enum.count(list), 2))

  @doc """
  Given a set of numbers and a specified sum, find the two values in the list
  that add up to the sum and return them, if they exist. Otherwise return
  nil. You can provide a single value to be skipped.

  Runs in O(n) time and space!
  """
  def two_sum(values, sum, skip \\ nil, skip_times \\ 1, cache \\ MapSet.new())
  def two_sum([], _, _, _, _), do: nil

  def two_sum([value | rest], sum, skip, skip_times, cache) do
    # If the current value is one that we specified to ignore, short-
    # circuit this iteration and move on to the next.
    if value == skip && skip_times > 0 do
      two_sum(rest, sum, skip, skip_times - 1, cache)
    end

    if MapSet.member?(cache, complement = sum - value) do
      # If the complement is present in the cache, then we've seen it
      # before, therefore it is definitely in the list of values.
      [value, complement]
    else
      two_sum(rest, sum, skip, skip_times, MapSet.put(cache, value))
    end
  end

  @doc """
  Given a set of numbers and a specified sum, find the three values in the
  list that add up to the sum and return them, if they exist. Otherwise
  return nil.

  Runs in O(n ^ 2) time.
  """
  def three_sum(values, sum, remaining \\ nil)
  def three_sum(_, _, []), do: nil

  def three_sum(values, sum, remaining) do
    [z | rest] = remaining || values

    case two_sum(values, sum - z, z) do
      nil -> three_sum(values, sum, rest)
      [x, y] -> [x, y, z]
    end
  end

  @doc """
  Greatest common divisor
  """
  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  @doc """
  The "extended Euclidean algorithm". Uh, see Wikipedia for more details.
  """
  def extended_gcd(a, b) do
    {old_r, r} = {a, b}
    {old_s, s} = {1, 0}
    {old_t, t} = {0, 1}

    extended_gcd_loop(r, old_r, s, old_s, t, old_t)
  end

  defp extended_gcd_loop(0, old_r, _, old_s, _, old_t),
    do: {old_r, old_s, old_t}

  defp extended_gcd_loop(r, old_r, s, old_s, t, old_t) do
    quotient = div(old_r, r)
    remainder = rem(old_r, r)

    {old_r, r} = {r, remainder}
    {old_s, s} = {s, old_s - quotient * s}
    {old_t, t} = {t, old_t - quotient * t}

    extended_gcd_loop(r, old_r, s, old_s, t, old_t)
  end

  @doc """
  Given signals that each have a period and a phase, combine them into a single
  signal and return the resulting period and phase.

  See this Stack Overflow page for more details:
    https://math.stackexchange.com/questions/2218763/how-to-find-lcm-of-two-numbers-when-one-starts-with-an-offset
  """
  def combine_phase_rotation({period_a, phase_a}, {period_b, phase_b}) do
    {gcd, s, _} = extended_gcd(period_a, period_b)
    phase_diff = phase_a - phase_b
    pd_mult = div(phase_diff, gcd)
    pd_rem = rem(phase_diff, gcd)

    if pd_rem != 0 do
      raise "sync never occurs!"
    end

    combined_period = div(period_a, gcd) * period_b
    combined_phase = rem(phase_a - s * pd_mult * period_a, combined_period)
    {combined_period, combined_phase}
  end

  def combine_phase_rotation([a, b]), do: combine_phase_rotation(a, b)

  def combine_phase_rotation([a | rest]),
    do: combine_phase_rotation(a, combine_phase_rotation(rest))

  @doc """
  Least common multiple
  """
  def lcm(a, b), do: div(abs(a * b), gcd(a, b))
  def lcm([a, b]), do: lcm(a, b)
  def lcm([a | rest]), do: lcm(a, lcm(rest))
end
