defmodule Advent2020 do
  alias Advent2020.BaggageRules
  alias Advent2020.BoardingPass
  alias Advent2020.ElfGame
  alias Advent2020.Expenses
  alias Advent2020.Interpreter
  alias Advent2020.Grid
  alias Advent2020.Navigation
  alias Advent2020.NavigationWithWaypoint
  alias Advent2020.Passport
  alias Advent2020.Password
  alias Advent2020.PortSystem
  alias Advent2020.PortSystemV2
  alias Advent2020.SeatSim
  alias Advent2020.TrainTickets
  alias Advent2020.Utilities
  alias Advent2020.Xmas

  def day1_1() do
    Utilities.file_to_list("../data/day1_1.txt")
    |> Enum.map(fn s -> String.to_integer(s) end)
    |> Expenses.expense_report(2020)
  end

  def day1_2() do
    Utilities.file_to_list("../data/day1_1.txt")
    |> Enum.map(fn s -> String.to_integer(s) end)
    |> Expenses.expense_report3(2020)
  end

  def day2_1() do
    Utilities.file_to_list("../data/day2_1.txt")
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.map(fn [policy, password | []] ->
      Password.check_against_policy_old(policy, password)
    end)
    |> Enum.count(fn result -> result == true end)
  end

  def day2_2() do
    Utilities.file_to_list("../data/day2_1.txt")
    |> Enum.map(fn line -> String.split(line, ": ") end)
    |> Enum.map(fn [policy, password | []] ->
      Password.check_against_policy_new(policy, password)
    end)
    |> Enum.count(fn result -> result == true end)
  end

  def day3_1() do
    Utilities.file_to_list("../data/day3_1.txt")
    |> Grid.from_list_of_strings()
    |> Grid.collect_in_slope_extend_x(3, 1)
    |> Enum.count(fn element -> element == "#" end)
  end

  def day3_2() do
    grid =
      Utilities.file_to_list("../data/day3_1.txt")
      |> Grid.from_list_of_strings()

    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.map(fn {dx, dy} ->
      Grid.collect_in_slope_extend_x(grid, dx, dy)
      |> Enum.count(fn element -> element == "#" end)
    end)
    |> Enum.reduce(fn x, acc -> acc * x end)
  end

  def day4_1() do
    Utilities.file_to_list("../data/day4_1.txt", trim: false)
    |> Utilities.file_lines_to_kv_pairs(":", [" ", "\n"], "")
    |> Enum.map(fn data -> Passport.ok?(data) end)
    |> Enum.count(fn result -> result == true end)
  end

  def day4_2() do
    Utilities.file_to_list("../data/day4_1.txt", trim: false)
    |> Utilities.file_lines_to_kv_pairs(":", [" ", "\n"], "")
    |> Enum.filter(fn data -> Passport.ok?(data) end)
    |> Enum.map(fn data -> struct(Passport, data) |> Passport.validate() end)
    |> Enum.count(fn result -> result != :error end)
  end

  def day5_1() do
    Utilities.file_to_list("../data/day5_1.txt")
    |> Enum.map(fn pass -> BoardingPass.get_seat(pass) end)
    |> Enum.map(fn pass -> BoardingPass.id(pass) end)
    |> Enum.max()
  end

  def day5_2() do
    Utilities.file_to_list("../data/day5_1.txt")
    |> Enum.map(fn pass -> BoardingPass.get_seat(pass) end)
    |> BoardingPass.find_empty_seats()
    |> BoardingPass.group_by_row()
    |> Enum.map(fn {k, v} -> {k, v} end)
    # If seat IDs +/- from ours are occupied, there must only be
    # a single empty seat in the row.
    |> Enum.filter(fn {_, cols} -> Enum.count(cols) == 1 end)
    |> List.first()
    |> (fn {row, [col | []]} -> {row, col} end).()
    |> BoardingPass.id()
  end

  # This is based on the recognition that the boarding pass data is
  # really just a 10-bit integer (7 bits for the row and 3 bits for
  # the seat). Converting that integer to decimal gives you the seat
  # ID, and you can carry on from there. The BSP stuff is a bit of a
  # red herring that leads you to implementing your own binary-to-
  # decimal parser. Fun, but not necessary to solve the problem.
  def day5_1_smarter(), do: day5_smart_processing() |> Enum.max()

  def day5_2_smarter() do
    day5_smart_processing()
    |> BoardingPass.find_empty_seats_by_id()
    |> Enum.sort(&(&1 < &2))
    # If seat IDs +/- from ours are occupied, there must only be
    # a single empty seat in the row. That would manifest as an
    # empty seat N where seats N-1 and N+1 are not present in the
    # set of empty seats.
    |> day5_2_smart_loop()
  end

  defp day5_smart_processing() do
    zeros = ~r/(F|L)/
    ones = ~r/(B|R)/

    regex_replace = fn string, regex, replacement ->
      Regex.replace(regex, string, replacement)
    end

    Utilities.file_to_list("../data/day5_1.txt")
    |> Enum.map(fn s ->
      s
      |> regex_replace.(zeros, "0")
      |> regex_replace.(ones, "1")
      |> Integer.parse(2)
      |> elem(0)
    end)
  end

  defp day5_2_smart_loop(list) do
    case list do
      # Examine a bank of three sequential empty seats.
      [x, y, z | rest] ->
        if y - x != 1 and z - y != 1 do
          # We found our seat!
          y
        else
          case rest do
            # We didn't find any seat meeting the criteria.
            [] -> nil
            # There are more seats to examine.
            _ -> day5_2_smart_loop([y, z | rest])
          end
        end
    end
  end

  def day6_1() do
    Utilities.file_to_list("../data/day6_1.txt", trim: false)
    |> Utilities.file_lines_to_char_sets("", fn current, new ->
      current = current || new
      MapSet.union(current, new)
    end)
    |> Enum.map(fn set -> Enum.count(set) end)
    |> Enum.reduce(fn count, sum -> sum + count end)
  end

  def day6_2() do
    Utilities.file_to_list("../data/day6_1.txt", trim: false)
    |> Utilities.file_lines_to_char_sets("", fn current, new ->
      current = current || new
      MapSet.intersection(current, new)
    end)
    |> Enum.map(fn set -> Enum.count(set) end)
    |> Enum.reduce(fn count, sum -> sum + count end)
  end

  def day7_1() do
    Utilities.file_to_list("../data/day7_1.txt")
    |> BaggageRules.add_rules()
    |> BaggageRules.find_bags_containing(:shinygold)
    |> Enum.count()
  end

  def day7_2() do
    # We need the number of bags held by "shiny gold", so we need
    # to deduct the count of "shiny gold" itself.
    (Utilities.file_to_list("../data/day7_1.txt")
     |> BaggageRules.add_rules()
     |> BaggageRules.bag_count(:shinygold)) - 1
  end

  def day8_1() do
    Utilities.file_to_list("../data/day8_1.txt")
    |> Interpreter.load()
    |> Interpreter.run(fn i -> i.acc end)
  end

  def day8_2() do
    i =
      Utilities.file_to_list("../data/day8_1.txt")
      |> Interpreter.load()

    keyed_inst = Interpreter.keyed_inst(i.inst)

    swap = %{
      nop: :jmp,
      jmp: :nop
    }

    # This is a brute force approach. We go through each instruction in the
    # program, and if the instruction is :nop or :jmp, we swap the instruction
    # at that position, then run the program and see if we finish without an
    # infinite loop. We skip running the program if the instruction we're
    # looking at isn't one of those two.
    day8_2_loop(
      i,
      keyed_inst,
      swap,
      Interpreter.modify_inst(keyed_inst, swap, 0),
      0
    )
  end

  defp day8_2_loop(i, keyed_inst, swap, modified_inst, candidate_pos) do
    {inst, _} = Enum.fetch!(i.inst, i.pc)

    if inst == :nop or inst == :jmp do
      case Interpreter.run(%{i | inst: modified_inst}, fn _ -> :failure end) do
        :failure ->
          day8_2_loop(
            i,
            keyed_inst,
            swap,
            Interpreter.modify_inst(keyed_inst, swap, candidate_pos + 1),
            candidate_pos + 1
          )

        acc ->
          acc
      end
    else
      day8_2_loop(
        i,
        keyed_inst,
        swap,
        Interpreter.modify_inst(keyed_inst, swap, candidate_pos + 1),
        candidate_pos + 1
      )
    end
  end

  def day9_1() do
    Utilities.file_to_list("../data/day9_1.txt")
    |> Enum.map(fn s -> String.to_integer(s) end)
    |> Xmas.find_not_sum(25)
  end

  def day9_2() do
    Utilities.file_to_list("../data/day9_1.txt")
    |> Enum.map(fn s -> String.to_integer(s) end)
    |> Xmas.find_sum_in_contiguous_range(day9_1())
    |> (fn slice -> [Enum.min(slice), Enum.max(slice)] end).()
    |> Enum.sum()
  end

  def day10_1() do
    Utilities.file_to_list("../data/day10_1.txt")
    |> Enum.map(fn s -> String.to_integer(s) end)
    |> Enum.sort()
    |> day10_1_loop()
    |> (fn %{1 => one, 3 => three} -> (one + 1) * (three + 1) end).()
  end

  def day10_1_loop(nums, cache \\ %{})
  def day10_1_loop([], cache), do: cache
  def day10_1_loop([_ | []], cache), do: cache

  def day10_1_loop([fst, snd | rest], cache) do
    # Essentially, count the gaps between each number in the sorted list.
    day10_1_loop(
      [snd | rest],
      Map.update(cache, snd - fst, 1, fn x -> x + 1 end)
    )
  end

  @doc """
  This is a little inscrutable; allow me to explain.

  If you take the sorted list of numbers and divide it into sublists that are
  each separated by 3 "jolts", then the total number of possible combinations
  is the product of the number of combinations of each sublist (because each
  sublist can only be "connected" in one way).

  The number of combinations that each sublist can have is simplified by two
  observations of the input data:
    1. Numbers are only separated by a gap of 1 or 3 in the sorted list,
       meaning that within each sublist, the numbers are contiguous, i.e.,
       have a gap of 1. This means we only need to care about the size of
       the sublists, not the contents.
    2. There's only a small number of distinct sublist sizes. In this case,
       they come in lengths of 1, 2, 3, 4, and 5.

  The number of combinations that can result from each sublist is determined
  by the number of "gap configurations" you can make. For example, for a
  sublist of size 4, the gap list of [1, 1, 1] can also be [1, 2], [2, 1],
  and [3], meaning that there are 4 total combinations.

  So we can just examine the length of each sublist, return the associated
  constant number of combinations, and multiply them together to get the
  total number of combinations for the whole list.

  People who are much smarter than me recognize that this is a "tribonacci
  sequence", and that the answer is as simple as 2^x * 4^y * 7^z, where
  x = the number of 3-element sublists, y = the number of 4-element
  sublists, and z = the number of 5-element sublists.
  """
  def day10_2() do
    Utilities.file_to_list("../data/day10_1.txt")
    |> Enum.map(fn s -> String.to_integer(s) end)
    |> Enum.sort()
    |> (fn nums -> [0 | nums] ++ [Enum.max(nums) + 3] end).()
    |> day10_2_split()
    |> Enum.map(fn xs -> Enum.reverse(xs) end)
    |> Enum.reverse()
    |> Enum.reduce(1, fn xs, acc -> acc * day10_2_combinations(xs) end)
  end

  def day10_2_split(nums, acc \\ [], split_nums \\ [])
  def day10_2_split([], _, split_nums), do: split_nums

  def day10_2_split([last | []], acc, split_nums) do
    [[last | acc] | split_nums]
  end

  def day10_2_split([fst, snd | rest], acc, split_nums) do
    if snd - fst >= 3 do
      day10_2_split([snd | rest], [], [[fst | acc] | split_nums])
    else
      day10_2_split([snd | rest], [fst | acc], split_nums)
    end
  end

  def day10_2_combinations(nums) do
    case Enum.count(nums) do
      1 -> 1
      2 -> 1
      3 -> 2
      4 -> 4
      5 -> 7
    end
  end

  def day11_1() do
    Utilities.file_to_list("../data/day11_1.txt")
    |> Grid.from_list_of_strings()
    |> SeatSim.new(occupied_to_empty: 4, empty_to_occupied: 0)
    |> SeatSim.run(&Grid.count_around/5)
    |> Grid.count_total("#")
  end

  def day11_2() do
    Utilities.file_to_list("../data/day11_1.txt")
    |> Grid.from_list_of_strings()
    |> SeatSim.new(occupied_to_empty: 5, empty_to_occupied: 0)
    |> SeatSim.run(&Grid.count_los/5)
    |> Grid.count_total("#")
  end

  def day12_1() do
    Utilities.file_to_list("../data/day12_1.txt")
    |> Enum.map(&Navigation.load_move/1)
    |> Navigation.run(%Navigation{})
    |> (fn n -> abs(n.x) + abs(n.y) end).()
  end

  def day12_2() do
    Utilities.file_to_list("../data/day12_1.txt")
    |> Enum.map(&Navigation.load_move/1)
    |> NavigationWithWaypoint.run(%NavigationWithWaypoint{wx: 10, wy: 1})
    |> (fn n -> abs(n.x) + abs(n.y) end).()
  end

  def day13_1() do
    [timestamp, bus_ids | _] = Utilities.file_to_list("../data/day13_1.txt")
    timestamp = String.to_integer(timestamp)

    bus_ids
    |> String.split(",")
    # Ignore out of service buses
    |> Enum.filter(fn id -> id != "x" end)
    |> Enum.map(fn id ->
      id
      |> String.to_integer()
      # For each bus, get the next departure time after the current time
      |> (fn id ->
            {Stream.iterate(ceil(timestamp / id) * id, fn x -> x + id end)
             |> Enum.take(1)
             |> (fn [x | []] -> x end).(), id}
          end).()
    end)
    # Sort to get the bus leaving earliest
    |> Enum.sort(fn {ts1, _}, {ts2, _} -> ts1 < ts2 end)
    |> Enum.take(1)
    |> (fn [x | []] -> x end).()
    |> (fn {ts, id} -> (ts - timestamp) * id end).()
  end

  @doc """
  This is kind of a trip. See commit b456b8f for the brute force solution
  that iterates from t=0 until it finds a timestamp that meets the
  conditions. That solution could take a thousand years to compute, so here's
  a galaxy-brain math solution.

  I started from the conjecture that if all the buses needed to leave at the
  same time (t>0), then the earliest such timestamp should be a multiple of
  the LCM of all the bus IDs. But each bus's desired departure is offset by a
  fixed amount relative to the others, so it's actually like a set of signals
  with periods and phases and the goal is to find the combined period of the
  whole system.

  A bit of Googling let me to the "extended Euclidean algorithm", which can be
  used to solve exactly what I described above. I have to stress that I don't
  totally understand the fundamental math behind this solution, and I
  essentially copied the implementations in `Utilities` from Wikipedia. But
  I think the important part is realizing that a solution that could be
  calculated in my lifetime lay in this domain.

  As it turns out, I think I inadvertently did something clever, because it's
  not immediately obvious that this solution should work. Here's my explanation
  for why it does actually work:

  At time t=0, all buses depart. We want to find a time t=N where the each of
  the next bus departures will match the pattern stipulated by the problem
  input. This solution reverses that, and says: If at time t=0, the next
  departure of each bus matches the pattern stipulated by the problem input,
  then there must be a time t=N where all the buses depart simultaneously.
  So if you can find that N, it's the same N that answers the original
  question, but the problem is now formulated in terms of finding the combined
  period/offset of a system of periods/offsets.

  PS: The extended Euclidean algorithm is useful for this case when the
  periods of each signal are co-prime, i.e., their GCD is 1. A quick visual
  inspection of the input shows that they're all odd numbers and *look* like
  primes. Maybe that would have been a clue to someone already familiar with
  this algorithm. Alternatively, someone familiar with cryptography might
  have immediately noticed it's a series of prime numbers and used the same
  algorithmic tools that are used to crunch RSA keys (no wonder it takes
  thousands of years to brute force).
  """
  def day13_2() do
    Utilities.file_to_list("../data/day13_1.txt")
    |> (fn [_, bus_ids | _] -> bus_ids end).()
    |> String.split(",")
    # The index is the "how many minutes later" each bus needs to depart
    |> Enum.with_index()
    # Remove irrelevant buses
    |> Enum.filter(fn {id, _} -> id != "x" end)
    |> Enum.map(fn {id, idx} -> {String.to_integer(id), idx} end)
    |> Utilities.combine_phase_rotation()
    # This phase is the offset of the combined signal, i.e., how far from t=0
    # it occurs for the first time. I believe this is negative due to the
    # conceptual reversal of the problem I discuss in the docstring.
    |> (fn {_, phase} -> -phase end).()
  end

  def day14_1() do
    Utilities.file_to_list("../data/day14_1.txt")
    |> PortSystem.init()
    |> Enum.map(fn {_, x} -> x end)
    |> Enum.sum()
  end

  def day14_2() do
    Utilities.file_to_list("../data/day14_1.txt")
    |> PortSystemV2.init()
    |> Enum.map(fn {_, x} -> x end)
    |> Enum.sum()
  end

  def day15_1() do
    Utilities.file_to_list("../data/day15_1.txt")
    |> List.first()
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(x) end)
    |> ElfGame.new()
    |> ElfGame.play(2020)
    |> (fn %{last_num: last_num} -> last_num end).()
  end

  def day15_2() do
    Utilities.file_to_list("../data/day15_1.txt")
    |> List.first()
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(x) end)
    |> ElfGame.new()
    |> ElfGame.play(30_000_000)
    |> (fn %{last_num: last_num} -> last_num end).()
  end

  def day16_1() do
    TrainTickets.parse("../data/day16_1.txt")
    |> (fn {rules, _, nearby_tickets} ->
          TrainTickets.check_all_tickets(nearby_tickets, rules)
        end).()
    |> (fn {_, invalid_vals} -> Enum.sum(invalid_vals) end).()
  end

  def day16_2() do
    {rules, your_ticket, nearby_tickets} =
      TrainTickets.parse("../data/day16_1.txt")

    {pos_valid_rules, _} = TrainTickets.check_all_tickets(nearby_tickets, rules)

    TrainTickets.identify_rules(pos_valid_rules)
    |> Enum.filter(fn {_, field} ->
      Atom.to_string(field) |> String.starts_with?("departure")
    end)
    |> Enum.map(fn {pos, _} ->
      Enum.fetch(your_ticket, pos) |> (fn {:ok, v} -> v end).()
    end)
    |> Enum.reduce(1, fn x, acc -> acc * x end)
  end
end
