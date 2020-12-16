defmodule Advent2020.ElfGame do
  defstruct turns: 0, starting_nums: [], last_num: nil, num_map: %{}

  def new(starting_nums) do
    %__MODULE__{starting_nums: starting_nums}
  end

  def next_num(%__MODULE__{} = game) do
    # We are in the starting numbers
    if game.turns < Enum.count(game.starting_nums) do
      Enum.fetch!(game.starting_nums, game.turns)
      # We are past the starting numbers
    else
      case Map.fetch!(game.num_map, game.last_num) do
        # The number has been said once
        {_} -> 0
        # The number has been said more than once
        {turn_p, turn_pp} -> turn_p - turn_pp
      end
    end
  end

  defp update_singtuple(singtuple, next) do
    case singtuple do
      {last} -> {next, last}
      {last, _} -> {next, last}
    end
  end

  def move(%__MODULE__{} = game) do
    next_num = next_num(game)
    turns = game.turns + 1

    %{
      game
      | turns: turns,
        last_num: next_num,
        num_map:
          Map.update(game.num_map, next_num, {turns}, fn current ->
            update_singtuple(current, turns)
          end)
    }
  end

  def play(%__MODULE__{} = game, until_turn) do
    next_state = move(game)

    if next_state.turns == until_turn + 1 do
      game
    else
      play(next_state, until_turn)
    end
  end
end
