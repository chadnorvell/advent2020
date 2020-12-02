defmodule Passwords do
  @doc """
  Check a password against a password policy that indicates a letter
  and the minimum and maximum number of times the letter must occur
  in the password.
  """
  def check_against_policy(policy, password) do
    [_ | [min_string | [max_string | [letter | []]]]] =
      Regex.run(~r/([\d]+)-([\d]+) ([a-zA-Z])/, policy)

    min = String.to_integer(min_string)
    max = String.to_integer(max_string)

    letter_occurrences = String.graphemes(password)
    |> Enum.count(fn char -> char == letter end)

    letter_occurrences >= min and letter_occurrences <= max
  end
end
