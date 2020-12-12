defmodule Advent2020.NavigationWithWaypoint do
  import Advent2020.Navigation, only: [add_angle: 2, dir_to_angle: 1]

  defstruct x: 0, y: 0, wx: 0, wy: 0, facing: :E

  def rotate_waypoint(angle, wx, wy) do
    case angle do
      0 -> {wx, wy}
      90 -> {-wy, wx}
      180 -> {-wx, -wy}
      270 -> {wy, -wx}
    end
  end

  def coord_to_waypoint(%__MODULE__{} = n, num) do
    {num * n.wx, num * n.wy}
  end

  def move(%__MODULE__{} = n, {command, num}) do
    case {command, num} do
      {:N, num} ->
        %{n | wy: n.wy + num}

      {:S, num} ->
        %{n | wy: n.wy - num}

      {:E, num} ->
        %{n | wx: n.wx + num}

      {:W, num} ->
        %{n | wx: n.wx - num}

      {:L, num} ->
        {wxx, wyy} =
          dir_to_angle(n.facing)
          |> add_angle(num)
          |> rotate_waypoint(n.wx, n.wy)

        %{n | wx: wxx, wy: wyy}

      {:R, num} ->
        {wxx, wyy} =
          dir_to_angle(n.facing)
          |> add_angle(-num)
          |> rotate_waypoint(n.wx, n.wy)

        %{n | wx: wxx, wy: wyy}

      {:F, num} ->
        move(n, {:G, coord_to_waypoint(n, num)})

      {:G, {dx, dy}} ->
        %{n | x: n.x + dx, y: n.y + dy}
    end
  end

  def run([], %__MODULE__{} = n), do: n

  def run([current | rest], %__MODULE__{} = n) do
    run(rest, move(n, current))
  end
end
