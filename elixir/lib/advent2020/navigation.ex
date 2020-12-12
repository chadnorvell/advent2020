defmodule Advent2020.Navigation do
  defstruct x: 0, y: 0, facing: :E

  def load_move(line) do
    [_, command, num] = Regex.run(~r/([A-Z])([0-9]+)/, line)
    {String.to_atom(command), String.to_integer(num)}
  end

  def angle_to_dir(angle) do
    case angle do
      0 -> :E
      90 -> :N
      180 -> :W
      270 -> :S
    end
  end

  def dir_to_angle(dir) do
    case dir do
      :E -> 0
      :N -> 90
      :W -> 180
      :S -> 270
    end
  end

  def add_angle(angle1, angle2) do
    sum = angle1 + angle2

    cond do
      sum == 360 -> 0
      sum > 360 -> add_angle(angle1, angle2 - 360)
      sum < 0 -> add_angle(angle1, angle2 + 360)
      true -> sum
    end
  end

  def move(%__MODULE__{} = n, {command, num}) do
    case {command, num} do
      {:N, num} ->
        %{n | y: n.y + num}

      {:S, num} ->
        %{n | y: n.y - num}

      {:E, num} ->
        %{n | x: n.x + num}

      {:W, num} ->
        %{n | x: n.x - num}

      {:L, num} ->
        %{
          n
          | facing: dir_to_angle(n.facing) |> add_angle(num) |> angle_to_dir()
        }

      {:R, num} ->
        %{
          n
          | facing: dir_to_angle(n.facing) |> add_angle(-num) |> angle_to_dir()
        }

      {:F, num} ->
        move(n, {n.facing, num})
    end
  end

  def run([], %__MODULE__{} = n), do: n

  def run([current | rest], %__MODULE__{} = n) do
    run(rest, move(n, current))
  end
end
