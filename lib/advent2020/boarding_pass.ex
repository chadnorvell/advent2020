defmodule Advent2020.BoardingPass do
  @row %{
    f: %{
      f: %{
        f: %{
          f: %{
            f: %{
              f: %{
                f: 0,
                b: 1
              },
              b: %{
                f: 2,
                b: 3
              }
            },
            b: %{
              f: %{
                f: 4,
                b: 5
              },
              b: %{
                f: 6,
                b: 7
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 8,
                b: 9
              },
              b: %{
                f: 10,
                b: 11
              }
            },
            b: %{
              f: %{
                f: 12,
                b: 13
              },
              b: %{
                f: 14,
                b: 15
              }
            }
          }
        },
        b: %{
          f: %{
            f: %{
              f: %{
                f: 16,
                b: 17
              },
              b: %{
                f: 18,
                b: 19
              }
            },
            b: %{
              f: %{
                f: 20,
                b: 21
              },
              b: %{
                f: 22,
                b: 23
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 24,
                b: 25
              },
              b: %{
                f: 26,
                b: 27
              }
            },
            b: %{
              f: %{
                f: 28,
                b: 29
              },
              b: %{
                f: 20,
                b: 31
              }
            }
          }
        }
      },
      b: %{
        f: %{
          f: %{
            f: %{
              f: %{
                f: 32,
                b: 33
              },
              b: %{
                f: 34,
                b: 35
              }
            },
            b: %{
              f: %{
                f: 36,
                b: 37
              },
              b: %{
                f: 38,
                b: 39
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 40,
                b: 41
              },
              b: %{
                f: 42,
                b: 43
              }
            },
            b: %{
              f: %{
                f: 44,
                b: 45
              },
              b: %{
                f: 46,
                b: 47
              }
            }
          }
        },
        b: %{
          f: %{
            f: %{
              f: %{
                f: 48,
                b: 49
              },
              b: %{
                f: 50,
                b: 51
              }
            },
            b: %{
              f: %{
                f: 52,
                b: 53
              },
              b: %{
                f: 54,
                b: 55
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 56,
                b: 57
              },
              b: %{
                f: 58,
                b: 59
              }
            },
            b: %{
              f: %{
                f: 60,
                b: 61
              },
              b: %{
                f: 62,
                b: 63
              }
            }
          }
        }
      }
    },
    b: %{
      f: %{
        f: %{
          f: %{
            f: %{
              f: %{
                f: 64,
                b: 65
              },
              b: %{
                f: 66,
                b: 67
              }
            },
            b: %{
              f: %{
                f: 68,
                b: 69
              },
              b: %{
                f: 70,
                b: 71
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 72,
                b: 73
              },
              b: %{
                f: 74,
                b: 75
              }
            },
            b: %{
              f: %{
                f: 76,
                b: 77
              },
              b: %{
                f: 78,
                b: 79
              }
            }
          }
        },
        b: %{
          f: %{
            f: %{
              f: %{
                f: 80,
                b: 81
              },
              b: %{
                f: 82,
                b: 83
              }
            },
            b: %{
              f: %{
                f: 84,
                b: 85
              },
              b: %{
                f: 86,
                b: 87
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 88,
                b: 89
              },
              b: %{
                f: 90,
                b: 91
              }
            },
            b: %{
              f: %{
                f: 92,
                b: 93
              },
              b: %{
                f: 94,
                b: 95
              }
            }
          }
        }
      },
      b: %{
        f: %{
          f: %{
            f: %{
              f: %{
                f: 96,
                b: 97
              },
              b: %{
                f: 98,
                b: 99
              }
            },
            b: %{
              f: %{
                f: 100,
                b: 101
              },
              b: %{
                f: 102,
                b: 103
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 104,
                b: 105
              },
              b: %{
                f: 106,
                b: 107
              }
            },
            b: %{
              f: %{
                f: 108,
                b: 109
              },
              b: %{
                f: 110,
                b: 111
              }
            }
          }
        },
        b: %{
          f: %{
            f: %{
              f: %{
                f: 112,
                b: 113
              },
              b: %{
                f: 114,
                b: 115
              }
            },
            b: %{
              f: %{
                f: 116,
                b: 117
              },
              b: %{
                f: 118,
                b: 119
              }
            }
          },
          b: %{
            f: %{
              f: %{
                f: 120,
                b: 121
              },
              b: %{
                f: 122,
                b: 123
              }
            },
            b: %{
              f: %{
                f: 124,
                b: 125
              },
              b: %{
                f: 126,
                b: 127
              }
            }
          }
        }
      }
    }
  }

  @col %{
    l: %{
      l: %{
        l: 0,
        r: 1
      },
      r: %{
        l: 2,
        r: 3
      }
    },
    r: %{
      l: %{
        l: 4,
        r: 5
      },
      r: %{
        l: 6,
        r: 7
      }
    }
  }

  @max_row 127
  @max_col 7

  @doc """
  Given a boarding pass seat code, return the row and column of the
  seat.
  """
  def get_seat(s) do
    {row_codes, col_codes} = s
    |> String.downcase()
    |> String.graphemes()
    |> Enum.split(7)

    {get_leaf(row_codes, @row), get_leaf(col_codes, @col)}
  end

  defp get_leaf([ current | rest ], tree) do
    case rest do
      [] -> tree[String.to_atom(current)]
      _ -> get_leaf(rest, tree[String.to_atom(current)])
    end
  end

  @doc """
  Return the seat ID.
  """
  def id({row, col}), do: row * 8 + col

  @doc """
  Find any empty seats based on boarding pass input.
  """
  def find_empty_seats(seats) do
    all_seats = MapSet.new(for row <- 0..@max_row, col <- 0..@max_col, do: {row, col})
    seats = MapSet.new(seats)

    MapSet.difference(all_seats, seats)
    |> MapSet.to_list()
  end

  def group_by_row([current | rest], acc \\ %{}) do
    case rest do
      [] -> acc
      _ -> group_by_row(
        rest,
        Map.update(acc, elem(current, 0), [elem(current, 1)], fn xs -> [elem(current, 1) | xs] end)
      )
    end
  end
end
