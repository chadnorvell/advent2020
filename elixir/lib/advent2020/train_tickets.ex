defmodule Advent2020.TrainTickets do
  alias Advent2020.Utilities

  @doc """
  Parse the train ticket input into useful data.
  """
  def parse(filename) do
    input = Utilities.file_to_list(filename, trim: false)

    {rules_strings, [_ | rest]} =
      Enum.split_while(input, fn line -> line != "" end)

    {[_, your_ticket_string], [_, _ | nearby_tickets_strings]} =
      Enum.split_while(rest, fn line -> line != "" end)

    rules =
      Enum.map(rules_strings, fn line ->
        [_, field, min1_string, max1_string, min2_string, max2_string | _] =
          Regex.run(~r/^([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)/, line)

        {String.to_atom(field), String.to_integer(min1_string),
         String.to_integer(max1_string), String.to_integer(min2_string),
         String.to_integer(max2_string)}
      end)

    your_ticket =
      String.split(your_ticket_string, ",") |> Enum.map(&String.to_integer/1)

    nearby_tickets =
      Enum.filter(nearby_tickets_strings, fn line -> line != "" end)
      |> Enum.map(fn line ->
        String.split(line, ",") |> Enum.map(&String.to_integer/1)
      end)

    {rules, your_ticket, nearby_tickets}
  end

  @doc """
  Given a rule and a value, return whether the value conforms to the rule.
  """
  def validate_on_rule({_, min1, max1, min2, max2}, num) do
    (num >= min1 and num <= max1) or (num >= min2 and num <= max2)
  end

  @doc """
  Given a value and a set of rules, return a set of rule names that the value
  conforms to.
  """
  def validate_on_all_rules(rules, num, valid_on_rules \\ MapSet.new())
  def validate_on_all_rules([], _, valid_on_rules), do: valid_on_rules

  def validate_on_all_rules(
        [{rule_name, _, _, _, _} = rule | rest],
        num,
        valid_on_rules
      ) do
    if validate_on_rule(rule, num) do
      validate_on_all_rules(rest, num, MapSet.put(valid_on_rules, rule_name))
    else
      validate_on_all_rules(rest, num, valid_on_rules)
    end
  end

  @doc """
  Given the data for one ticket and a set of rules, return:
  - A map associating a value's position in the list of values with a set of
    rule names that the value in that position conforms to.
  - A list of values that don't conform to any rules at all.
  """
  def check_ticket(vals, rules, pos_valid_rules \\ %{}, invalid_vals \\ [])

  def check_ticket([], _, pos_valid_rules, invalid_vals),
    do: {pos_valid_rules, invalid_vals}

  def check_ticket(
        [{current_val, pos} | rest_vals],
        rules,
        pos_valid_rules,
        invalid_vals
      ) do
    this_value_valid_rules = validate_on_all_rules(rules, current_val)

    new_set =
      Map.update(pos_valid_rules, pos, this_value_valid_rules, fn set ->
        MapSet.put(set, this_value_valid_rules)
      end)

    new_invalid_vals =
      if this_value_valid_rules == MapSet.new() do
        [current_val | invalid_vals]
      else
        invalid_vals
      end

    check_ticket(rest_vals, rules, new_set, new_invalid_vals)
  end

  @doc """
  Given data for all tickets and a set of rules, return:
  - A map associating a position in each ticket data set with the names of the
    rules that are satisfied by every ticket.
  - A list of all values that don't conform to any rules at all.
  """
  def check_all_tickets(
        tickets,
        rules,
        pos_valid_rules \\ %{},
        invalid_vals \\ []
      )

  def check_all_tickets([], _, pos_valid_rules, invalid_vals),
    do: {pos_valid_rules, invalid_vals}

  def check_all_tickets(
        [current_ticket | rest_tickets],
        rules,
        pos_valid_rules,
        invalid_vals
      ) do
    {pos_valid_rules_this_ticket, invalid_vals_this_ticket} =
      check_ticket(Enum.with_index(current_ticket), rules)

    case invalid_vals_this_ticket do
      [] ->
        check_all_tickets(
          rest_tickets,
          rules,
          Map.merge(pos_valid_rules, pos_valid_rules_this_ticket, fn _,
                                                                     prev,
                                                                     this ->
            MapSet.intersection(this, prev)
          end),
          invalid_vals
        )

      _ ->
        check_all_tickets(
          rest_tickets,
          rules,
          pos_valid_rules,
          invalid_vals_this_ticket ++ invalid_vals
        )
    end
  end

  @doc """
  Given a map associating a position in each ticket data set with the names of
  the rules that are satisfied by every ticket, identify the single rule
  associated with each position.
  """
  def identify_rules(pos_valid_rules, found_assocs \\ %{})

  def identify_rules(%{} = pos_valid_rules, found_assocs)
      when pos_valid_rules == %{},
      do: found_assocs

  def identify_rules(%{} = pos_valid_rules, found_assocs) do
    # Find the first entry that has a single rule name in its set
    {pos, field} =
      Enum.find(pos_valid_rules, fn {_, set} -> Enum.count(set) == 1 end)
      |> (fn {pos, set} -> {pos, MapSet.to_list(set) |> List.first()} end).()

    # The rule is associated with that position, and the rule name is removed
    # from all other position sets
    new_pos_valid_rules =
      Map.delete(pos_valid_rules, pos)
      |> Enum.map(fn {pos, set} -> {pos, MapSet.delete(set, field)} end)
      |> Enum.into(%{})

    # Iterate until all positions are accounted for
    identify_rules(new_pos_valid_rules, Map.put(found_assocs, pos, field))
  end
end
