defmodule Advent2020.SeatSim do
  @moduledoc """
  Simulate filling seats!
  """

  alias Advent2020.Grid

  defstruct ~w(current previous changed occupied_to_empty empty_to_occupied)a

  @empty "L"
  @occupied "#"
  @floor "."

  @doc """
  Create a new grid. Use this instead of directly instantiating.
  """
  def new(grid,
        occupied_to_empty: occupied_to_empty,
        empty_to_occupied: empty_to_occupied
      ) do
    %__MODULE__{
      current: grid,
      previous: grid,
      occupied_to_empty: occupied_to_empty,
      empty_to_occupied: empty_to_occupied
    }
  end

  @doc """
  Iterate through the grid once, applying the rules to each seat.
  """
  def step(%__MODULE__{} = sim, sight_fn, cur_row \\ 0, cur_col \\ 0) do
    {:ok, cur_seat} = Grid.get(sim.previous, cur_col, cur_row)

    occupied_seats =
      if cur_seat != @floor do
        sight_fn.(sim.previous, cur_col, cur_row, @occupied, ["."])
      else
        0
      end

    new_state =
      cond do
        cur_seat == @empty and occupied_seats == sim.empty_to_occupied ->
          %{
            sim
            | current: Grid.update(sim.current, cur_col, cur_row, @occupied),
              previous: sim.previous
          }

        cur_seat == @occupied and occupied_seats >= sim.occupied_to_empty ->
          %{
            sim
            | current: Grid.update(sim.current, cur_col, cur_row, @empty),
              previous: sim.previous
          }

        true ->
          sim
      end

    if cur_col < tuple_size(elem(sim.current, 0)) - 1 do
      step(new_state, sight_fn, cur_row, cur_col + 1)
    else
      if cur_row < tuple_size(sim.current) - 1 do
        step(new_state, sight_fn, cur_row + 1, 0)
      else
        %{
          new_state
          | previous: new_state.current,
            changed: new_state.current != new_state.previous
        }
      end
    end
  end

  @doc """
  Apply the rules to each seat repeatedly until applying the rules no longer
  has any effect.
  """
  def run(%__MODULE__{changed: false} = sim, _), do: sim.current

  def run(%__MODULE__{changed: nil} = sim, sight_fn),
    do: run(step(sim, sight_fn), sight_fn)

  def run(%__MODULE__{changed: true} = sim, sight_fn),
    do: run(step(sim, sight_fn), sight_fn)
end
