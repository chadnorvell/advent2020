defmodule Advent2020.Passport do
  @moduledoc """
  A data structure representing a Passport.
  """

  @enforce_keys ~w(byr iyr eyr hgt hcl ecl pid)a
  defstruct ~w(byr iyr eyr hgt hcl ecl pid cid)a

  def valid?(map) do
    try do
      struct!(__MODULE__, map)
      true
    rescue
      _ in ArgumentError -> false
    end
  end
end
