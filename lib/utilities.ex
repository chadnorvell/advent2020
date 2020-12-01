defmodule Advent2020.Utilities do
  @doc """
  Given a file with desired values on each line, return a list of
  those values.
  """
  def file_to_list(file_name) do
    File.read!(file_name)
    |> String.split("\n", trim: true)
  end
end
