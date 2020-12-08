defmodule Advent2020.Passport do
  @moduledoc """
  A data structure representing a Passport.
  """

  @enforce_keys ~w(byr iyr eyr hgt hcl ecl pid)a
  defstruct ~w(byr iyr eyr hgt hcl ecl pid cid)a

  @eye_colors ~w(amb blu brn gry grn hzl oth)

  defp parse_year(s) do
    if String.length(s) == 4 do
      # Will return an integer or `:error`
      {integer, _} = Integer.parse(s)
      integer
    else
      :error
    end
  end

  def validate_year(:error, _, _, _), do: :error

  def validate_year(%__MODULE__{} = passport, key, min, max) do
    case parse_year(Map.fetch!(passport, key)) do
      :error ->
        :error

      year ->
        if year >= min and year <= max do
          Map.update(passport, key, year, fn _ -> year end)
        else
          :error
        end
    end
  end

  def validate_height(:error), do: :error

  def validate_height(%__MODULE__{} = passport) do
    case Integer.parse(passport.hgt) do
      :error ->
        :error

      {num, units} ->
        case units do
          "cm" ->
            if num >= 150 and num <= 193 do
              Map.update(
                passport,
                :hgt,
                {num, "cm"},
                fn _ -> {num, "cm"} end
              )
            else
              :error
            end

          "in" ->
            if num >= 59 and num <= 76 do
              Map.update(
                passport,
                :hgt,
                {num, "in"},
                fn _ -> {num, "in"} end
              )
            else
              :error
            end

          _ ->
            :error
        end
    end
  end

  def validate_hair_color(:error), do: :error

  def validate_hair_color(%__MODULE__{} = passport) do
    case String.match?(passport.hcl, ~r/^#[0-9a-f]{6}$/) do
      true -> passport
      false -> :error
    end
  end

  def validate_eye_color(:error), do: :error

  def validate_eye_color(%__MODULE__{} = passport) do
    case Enum.member?(@eye_colors, passport.ecl) do
      true ->
        Map.update(
          passport,
          :ecl,
          String.to_atom(passport.ecl),
          fn _ -> String.to_atom(passport.ecl) end
        )

      false ->
        :error
    end
  end

  def validate_pid(:error), do: :error

  def validate_pid(%__MODULE__{} = passport) do
    is_number =
      case Integer.parse(passport.pid) do
        :error -> false
        {_, rem} -> rem == ""
      end

    case String.length(passport.pid) == 9 and is_number do
      true -> passport
      false -> :error
    end
  end

  @doc """
  Validate the data in the passport, converting the string input data
  to more appropriate data types where needed.
  """
  def validate(%__MODULE__{} = passport) do
    passport
    |> validate_year(:byr, 1920, 2002)
    |> validate_year(:iyr, 2010, 2020)
    |> validate_year(:eyr, 2020, 2030)
    |> validate_height()
    |> validate_hair_color()
    |> validate_eye_color()
    |> validate_pid()
  end

  @doc """
  Check whether the passport data has all required fields.
  """
  def ok?(map) do
    try do
      struct!(__MODULE__, map)
      true
    rescue
      _ in ArgumentError -> false
    end
  end
end
