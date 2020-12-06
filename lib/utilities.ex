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
      [] -> groups
      # We're not done; process the next line.
      [ current_line | rest ] ->
        case current_line do
          # This line is a separator between groups.
          # So the current group is finished and we will start a new
          # one on the next iteration.
          ^group_delimiter -> file_lines_to_kv_pairs(
            rest, kv_delimiter, pair_delimiters, group_delimiter, %{}, [current_group | groups]
          )
          # This line starts or adds to a group.
          line_with_kv -> file_lines_to_kv_pairs(
            rest,
            kv_delimiter,
            pair_delimiters,
            group_delimiter,
            decode_kv_pairs(line_with_kv, kv_delimiter, pair_delimiters, current_group),
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
      [] -> groups
      # We're not done; process the next line.
      [ current_line | rest ] ->
        case current_line do
            # This line is a separator between groups.
            # So the current group is finished and we will start a new
            # one on the next iteration.
            ^group_delimiter -> file_lines_to_char_sets(
              rest, group_delimiter, mapset_merge_fn, nil, [current_group | groups]
            )
            # This line starts or adds to a group.
            line_with_chars -> file_lines_to_char_sets(
              rest,
              group_delimiter,
              mapset_merge_fn,
              mapset_merge_fn.(current_group, string_to_char_mapset(line_with_chars)),
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
end
