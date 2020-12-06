defmodule Advent2020Test do
  use ExUnit.Case
  doctest Advent2020

  test "day 1 part 1" do
    assert Advent2020.day1_1() == 471019
  end

  test "day 1 part 2" do
    assert Advent2020.day1_2() == 103927824
  end

  test "day 2 part 1" do
    assert Advent2020.day2_1() == 458
  end

  test "day 2 part 2" do
    assert Advent2020.day2_2() == 342
  end

  test "day 3 part 1" do
    assert Advent2020.day3_1() == 272
  end

  test "day 3 part 2" do
    assert Advent2020.day3_2() == 3898725600
  end

  test "day 4 part 1" do
    assert Advent2020.day4_1() == 213
  end

  test "day 4 part 2" do
    assert Advent2020.day4_2() == 147
  end

  test "day 5 part 1" do
    assert Advent2020.day5_1() == 828
  end

  test "day 5 part 2" do
    assert Advent2020.day5_2() == 565
  end

  test "day 6 part 1" do
    assert Advent2020.day6_1() == 6775
  end

  test "day 6 part 2" do
    assert Advent2020.day6_2() == 3356
  end
end
