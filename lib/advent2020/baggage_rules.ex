defmodule Advent2020.BaggageRules do
  @moduledoc """
  Represent the truly bizarre baggage rules using a graph. I was too lazy to
  implement a graph data structure myself, so I pulled in a library.
  """

  defp smush_bag_name(bag_names) do
    Enum.join(bag_names)
    |> String.trim()
    |> String.replace(" ", "")
    |> String.to_atom()
  end

  @doc """
  Add the rules for one bag to the rule set.
  """
  def add_rule(rule_string, %Graph{} = rules \\ %Graph{}) do
    [source_bag_name, edge_data_string] =
      String.split(rule_string, " bags contain ")

    source = smush_bag_name([source_bag_name])

    # Add the bag type to the graph. If it's already there, this is a no-op.
    rules = Graph.add_vertex(rules, source)

    # Convert the rest of the string into a keyword list of bag names and
    # the number assocated with the edge.
    String.split(edge_data_string, [",", "."])
    |> Enum.map(fn s ->
      cond do
        s == "" ->
          nil

        s == "no other bags" ->
          nil

        String.match?(s, ~r/(\d+) (\w+) (\w+)/) ->
          [_, num, w1, w2] = Regex.run(~r/(\d+) (\w+) (\w+)/, s)
          {smush_bag_name([w1, w2]), num}
      end
    end)
    |> Enum.filter(fn x -> x != nil end)
    # Then create new graph edges for each set of edge data. Note that we swap
    # source and dest, because we want the graph to be directed opposite the
    # direction implied by the text rules, so that we can start at the vertex
    # we care about and traverse the graph from there.
    |> Enum.map(fn {dest, num} ->
      Graph.Edge.new(dest, source, weight: String.to_integer(num))
    end)
    # Insert those edges into the graph.
    |> (fn edges -> Graph.add_edges(rules, edges) end).()
  end

  @doc """
  Add rules for many bags to the rule set.
  """
  def add_rules(rule_strings, rules \\ %Graph{})

  def add_rules([], %Graph{} = rules), do: rules

  def add_rules([current | rest], %Graph{} = rules) do
    add_rules(rest, add_rule(current, rules))
  end

  def find_bags_containing(rules, bag) do
    Graph.reachable_neighbors(rules, [bag])
  end
end
