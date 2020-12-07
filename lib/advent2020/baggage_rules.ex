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
    # Then create new graph edges for each set of edge data.
    |> Enum.map(fn {dest, num} ->
      Graph.Edge.new(source, dest, weight: String.to_integer(num))
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

  @doc """
  Find every bag that can contain this bag.
  """
  def find_bags_containing(rules, bag) do
    Graph.reaching_neighbors(rules, [bag])
  end

  @doc """
  Get a count of the number of bags held by this bag, including itself.
  (Note that "including itself" is a little odd, but necessary for the
  recursion to work.)
  """
  def bag_count(rules, vertex) do
    subgraph = Graph.subgraph(rules, Graph.reachable(rules, [vertex]))
    neighbors = Graph.out_neighbors(subgraph, vertex)

    held_bags =
      Enum.map(neighbors, fn neighbor ->
        %{weight: num} = Graph.edge(subgraph, vertex, neighbor)
        {neighbor, num}
      end)

    # Each bag's count is 1 (for the bag itself) plus the sum of the count of
    # bags that it holds.
    case held_bags do
      [] ->
        1

      _ ->
        1 +
          (Enum.map(held_bags, fn {neighbor, num} ->
             num * bag_count(rules, neighbor)
           end)
           |> Enum.sum())
    end
  end
end
