defmodule Advent2020.Password do
  alias Advent2020.Utilities

  @doc """
  Check a password against a password policy that indicates a letter
  and the minimum and maximum number of times the letter must occur
  in the password.
  """
  def check_against_policy_old(policy, password) do
    [_ | [min_string | [max_string | [letter | []]]]] =
      Regex.run(~r/([\d]+)-([\d]+) ([a-zA-Z])/, policy)

    min = String.to_integer(min_string)
    max = String.to_integer(max_string)

    letter_occurrences = String.graphemes(password)
    |> Enum.count(fn char -> char == letter end)

    letter_occurrences >= min and letter_occurrences <= max
  end

  @doc """
  Check a password against a password policy that indicates a letter
  and two positions where the letter must occur exactly once in the
  passwword.
  """
  def check_against_policy_new(policy, password) do
    [_ | [pos1_string | [pos2_string | [letter | []]]]] =
      Regex.run(~r/([\d]+)-([\d]+) ([a-zA-Z])/, policy)

    pos1 = String.to_integer(pos1_string)
    pos2 = String.to_integer(pos2_string)
    password_letters = String.graphemes(password)

    pos1_value = Enum.fetch!(password_letters, pos1 - 1)
    pos2_value = Enum.fetch!(password_letters, pos2 - 1)

    Utilities.xor(pos1_value == letter, pos2_value == letter)
  end
end
