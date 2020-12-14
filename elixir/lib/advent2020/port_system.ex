defmodule Advent2020.PortSystem do
  use Bitwise

  @mask_regex ~r/mask = ([01X]+)/
  @mem_regex ~r/mem\[(\d+)\] = (\d+)/

  @doc """
  Bitwise OR this mask to set 1 bits.
  """
  def on_mask(chars) do
    chars
    |> Enum.map(fn c ->
      case c do
        "0" -> 0
        "1" -> 1
        "X" -> 0
      end
    end)
    |> Enum.into(<<>>, fn bit -> <<bit::1>> end)
    |> :binary.decode_unsigned()
  end

  @doc """
  Bitwise AND this mask to clear 0 bits.
  """
  def off_mask(chars) do
    chars
    |> Enum.map(fn c ->
      case c do
        "0" -> 0
        "1" -> 1
        "X" -> 1
      end
    end)
    |> Enum.into(<<>>, fn bit -> <<bit::1>> end)
    |> :binary.decode_unsigned()
  end

  @doc """
  Return a function that masks the input value.
  """
  def make_mask_fn(mask_string) do
    # This is really SAD, but Elixir/Erlang don't have bitwise operations on
    # bitstrings, despite the fact that bitstrings exist in the first place.
    # Bitwise operations can only be done on integers, which need to be formed
    # from bytes. So we need to pad the bitmask with 4 no-op bits simply
    # because of this language deficiency.
    mask_string_chars = String.graphemes("XXXX" <> mask_string)
    {on_mask(mask_string_chars), off_mask(mask_string_chars)}

    fn num ->
      (on_mask(mask_string_chars) ||| num) &&& off_mask(mask_string_chars)
    end
  end

  @doc """
  Run through a list of instructions, setting memory locations with values
  modified by the most recent bitmask.
  """
  def init(lines, mem \\ %{}, mask_fn \\ nil)
  def init([], mem, _), do: mem

  def init([current | rest], mem, mask_fn) do
    cond do
      String.match?(current, @mask_regex) ->
        [_, mask_string | _] = Regex.run(@mask_regex, current)
        init(rest, mem, make_mask_fn(mask_string))

      String.match?(current, @mem_regex) ->
        [_, loc, num | _] = Regex.run(@mem_regex, current)
        mem_val = mask_fn.(String.to_integer(num))

        init(
          rest,
          Map.update(mem, String.to_integer(loc), mem_val, fn _ -> mem_val end),
          mask_fn
        )
    end
  end
end
