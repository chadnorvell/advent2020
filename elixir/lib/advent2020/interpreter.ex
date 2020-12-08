defmodule Advent2020.Interpreter do
  @moduledoc """
  An interpreter for "handheld game console" assembly language! Each instance
  of this struct represents a discrete interpreter state.
  """

  defstruct inst: [], pc: 0, acc: 0, rc: %{}

  @doc """
  Load a list of string-encoded instructions into a fresh interpreter
  instance.
  """
  def load(lines) do
    inst =
      preload(lines)
      |> Enum.reverse()

    %__MODULE__{inst: inst}
  end

  defp preload(lines, inst \\ [])
  defp preload([], inst), do: inst

  defp preload([current | rest], inst) do
    [inst_string, val_string] = String.split(current, " ")

    preload(rest, [
      {String.to_atom(inst_string), String.to_integer(val_string)} | inst
    ])
  end

  @doc """
  Given an instruction list, return a map keying each instruction to its
  position in the list.
  """
  def keyed_inst(inst) do
    Enum.with_index(inst)
    |> Enum.map(fn {inst, idx} -> {idx, inst} end)
    |> Enum.into(%{})
  end

  @doc """
  Given keyed instructions, a map indicating instructions to change, and the
  instruction position to change, return a new ordered instruction list.
  """
  def modify_inst(keyed_inst, swap, pos) do
    case keyed_inst[pos] do
      {key, val} ->
        if Enum.member?(Map.keys(swap), key) do
          keyed_inst
          |> Map.delete(pos)
          |> Map.put(pos, {swap[key], val})
        else
          keyed_inst
        end

      _ ->
        keyed_inst
    end
    |> Enum.map(fn {idx, inst} -> {idx, inst} end)
    |> Enum.sort(fn {idx1, _}, {idx2, _} -> idx1 < idx2 end)
    |> Enum.map(fn {_, inst} -> inst end)
  end

  @doc """
  Execute a single instruction, based on the provided interpreter's state.
  """
  def step(%__MODULE__{} = i) do
    rc = Map.update(i.rc, i.pc, 1, fn cur -> cur + 1 end)

    try do
      case Enum.fetch!(i.inst, i.pc) do
        {:nop, _} -> %{i | rc: rc, pc: i.pc + 1}
        {:acc, val} -> %{i | rc: rc, pc: i.pc + 1, acc: i.acc + val}
        {:jmp, val} -> %{i | rc: rc, pc: i.pc + val}
      end
    rescue
      # If we access an instruction out of the bounds of the instruction list,
      # then the program is finished executing, and we return the accumulator.
      _ in Enum.OutOfBoundsError -> i.acc
    end
  end

  @doc """
  Run a program. The program will end under two conditions:
    1. The interpreter tries to access an instruction beyond the end of the
       instruction list.
    2. An infinte loop is detected, which is rescued by the provided callback.
  """
  def run(%__MODULE__{} = i, rescue_infinite_loop \\ fn i -> i.acc end) do
    case step(i) do
      # A new interpreter state was returned, so the program is still running.
      %__MODULE__{} = next ->
        # If an infinite loop is detected, run the provided callback and end
        # execution. (This method of detecting an infinite loop by checking if
        # an instruction is being run a second time only works because of the
        # limited instruction set of this machine.)
        if Enum.any?(next.rc, fn {_, count} -> count > 1 end) do
          rescue_infinite_loop.(i)
        else
          run(next, rescue_infinite_loop)
        end

      # The accumulator was returned, so the program finished.
      acc ->
        acc
    end
  end
end
