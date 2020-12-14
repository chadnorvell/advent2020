defmodule Advent2020.PortSystemV2 do
  import Advent2020.PortSystem, only: [off_mask: 1, on_mask: 1]
  import Advent2020.Utilities, only: [cartesian_product: 1]
  use Bitwise

  @mask_regex ~r/mask = ([01X]+)/
  @mem_regex ~r/mem\[(\d+)\] = (\d+)/

  @doc """
  Generate actual masks from an input mask string with floating bits. For
  each combination of those floating bits, this returns both an "on mask" (to
  bitwise OR to set 1s) and an "off mask" (to bitwise AND to clear 0s).
  """
  def generate_floating_masks(cs) do
    # Get the position of each varying bit and generate possible values
    {v, pos} =
      cs
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c == "X" end)
      |> Enum.map(fn {_, idx} -> {["0", "1"], idx} end)
      |> Enum.unzip()

    # Convert those positions to atoms to facilitate merging the lists later
    pos_atoms =
      Enum.map(pos, fn p -> p |> Integer.to_string() |> String.to_atom() end)

    # Generate every combination of the varying bits
    floating =
      Enum.map(cartesian_product(v), fn x -> Enum.zip(pos_atoms, x) end)

    # Regenerate the fixed bits, replacing them with "X" to facilitate generating
    # appropriate bit masks later
    fixed =
      Enum.with_index(cs)
      |> Enum.filter(fn {c, _} -> c != "X" end)
      |> Enum.map(fn {_, idx} ->
        {idx |> Integer.to_string() |> String.to_atom(), "X"}
      end)

    # Merge the varying and fixed bits back together and generate on and off masks
    floating
    |> Enum.map(fn variety -> Keyword.merge(fixed, variety) end)
    |> Enum.map(fn xs ->
      xs
      |> Enum.map(fn {pos_atom, c} ->
        {pos_atom |> Atom.to_string() |> String.to_integer(), c}
      end)
      |> Enum.sort(fn {p1, _}, {p2, _} -> p1 < p2 end)
      |> Enum.map(fn {_, c} -> c end)
      |> (fn xs -> {on_mask(xs), off_mask(xs)} end).()
    end)
  end

  @doc """
  Return a function that masks a memory location, producing a list of memory
  locations formed from all combinations of the floating bits.
  """
  def make_mask_fn(mask_string) do
    mask_string_chars = String.graphemes("0000" <> mask_string)

    fixed_on_mask = on_mask(mask_string_chars)
    floating_masks = generate_floating_masks(mask_string_chars)

    fn num ->
      Enum.map(floating_masks, fn {floating_on_mask, floating_off_mask} ->
        (floating_on_mask ||| (fixed_on_mask ||| num)) &&& floating_off_mask
      end)
    end
  end

  @doc """
  Run through a list of instructions, setting values to memory locations
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
        mem_val = String.to_integer(num)

        updated_mem =
          mask_fn.(String.to_integer(loc))
          |> Enum.map(fn loc -> {loc, mem_val} end)
          |> Enum.into(%{})

        init(rest, Map.merge(mem, updated_mem), mask_fn)
    end
  end
end
