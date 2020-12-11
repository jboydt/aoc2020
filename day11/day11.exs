defmodule Day11 do
  @filename "input.txt"

  def run() do
    IO.puts("Day 11\n")

    case process(@filename) do
      {:ok, occupied, deep_occupied} ->
        IO.puts("Part 1: occupied seats = #{occupied}")
        IO.puts("Part 2: deep occupied seats = #{deep_occupied}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        seats =
          contents
          |> String.trim()
          |> String.split("\n")
          |> make_all_seats()

        occupied =
          seats
          |> process_seats(&get_neighbors/3, 4)
          |> count_used()

        deep_occupied =
          seats
          |> process_seats(&get_deep_neighbors/3, 5)
          |> count_used()

        {:ok, occupied, deep_occupied}

      error ->
        error
    end
  end

  defp count_used(seats) do
    seats
    |> Map.keys()
    |> Enum.reduce(0, fn k, acc ->
      count_used_in_row(seats[k]) + acc
    end)
  end

  defp count_used_in_row(row) do
    row
    |> Map.keys()
    |> Enum.reduce(0, fn k, acc ->
      case seat_is_used(row[k]) do
        true -> 1 + acc
        false -> acc
      end
    end)
  end

  defp seat_is_used(%{current: :used}), do: true
  defp seat_is_used(_), do: false

  defp process_seats(seats, find_func, min) do
    updated_seats = update_seats(seats, find_func, min)
    # print_seats(updated_seats)

    if updated_seats == seats do
      updated_seats
    else
      process_seats(updated_seats, find_func, min)
    end
  end

  defp update_seats(seats, find_func, min) do
    seats
    |> Map.keys()
    |> Enum.reduce(%{}, fn k, acc ->
      Map.put(acc, k, update_row(seats, k, find_func, min))
    end)
  end

  defp update_row(seats, row, find_func, min) do
    seats[row]
    |> Map.keys()
    |> Enum.reduce(%{}, fn k, acc ->
      Map.put(acc, k, update_seat(seats, row, k, find_func, min))
    end)
  end

  defp update_seat(seats, row, column, find_func, min) do
    seats
    |> find_func.(row, column)
    |> apply_seat_rules(seats[row][column], min)
  end

  defp apply_seat_rules(_, %{current: :floor} = seat, _), do: seat

  defp apply_seat_rules(neighbors, %{current: :used} = seat, min) do
    case count_occupied(neighbors, min) do
      true -> %{current: :open, last: :used}
      false -> seat
    end
  end

  defp apply_seat_rules(neighbors, %{current: :open} = seat, _) do
    case Enum.all?(neighbors, &empty_seat(&1)) do
      true -> %{current: :used, last: :open}
      false -> seat
    end
  end

  defp count_occupied(neighbors, min) do
    occupied =
      neighbors
      |> Enum.filter(fn %{current: c} -> c == :used end)
      |> Enum.count()

    occupied >= min
  end

  defp empty_seat(%{current: :floor}), do: true
  defp empty_seat(%{current: :open}), do: true
  defp empty_seat(_), do: false

  defp get_neighbors(seats, row, column) do
    [
      {row - 1, column - 1},
      {row - 1, column},
      {row - 1, column + 1},
      {row, column - 1},
      {row, column + 1},
      {row + 1, column - 1},
      {row + 1, column},
      {row + 1, column + 1}
    ]
    |> Enum.reduce([], fn {r, c}, acc ->
      acc ++ [seats[r][c]]
    end)
    |> Enum.filter(fn n -> n != nil end)
  end

  defp get_deep_neighbors(seats, row, column) do
    [
      {-1, -1},
      {-1, 0},
      {-1, 1},
      {0, -1},
      {0, 1},
      {1, -1},
      {1, 0},
      {1, 1}
    ]
    |> Enum.reduce([], fn {rdir, cdir}, acc ->
      acc ++ [next_in_view(seats, rdir, cdir, row + rdir, column + cdir)]
    end)
    |> Enum.filter(fn n -> n != nil end)
  end

  defp next_in_view(seats, rdir, cdir, row, column) do
    seat = seats[row][column]

    cond do
      seat == nil -> nil
      seat.current == :used -> seat
      seat.current == :open -> seat
      true -> next_in_view(seats, rdir, cdir, row + rdir, column + cdir)
    end
  end

  defp make_all_seats(input) do
    input
    |> Enum.reduce(%{row: 0}, fn r, acc ->
      Map.put(acc, acc.row, make_row_seats(r))
      |> Map.update!(:row, &(&1 + 1))
    end)
    |> Map.drop([:row])
  end

  defp make_row_seats(input) do
    input
    |> String.to_charlist()
    |> Enum.reduce(%{column: 0}, fn s, acc ->
      Map.put(acc, acc.column, make_seat(s))
      |> Map.update!(:column, &(&1 + 1))
    end)
    |> Map.drop([:column])
  end

  defp make_seat(?.), do: %{current: :floor, last: :floor}
  defp make_seat(?L), do: %{current: :open, last: :open}

  # defp print_seats(seats) do
  #   seats
  #   |> Map.keys()
  #   |> Enum.each(fn k ->
  #     print_row(seats[k])
  #   end)
  #
  #   IO.puts("")
  # end
  #
  # defp print_row(row) do
  #   row
  #   |> Map.keys()
  #   |> Enum.each(fn k ->
  #     print_seat(row[k])
  #   end)
  #
  #   IO.puts("")
  # end
  #
  # defp print_seat(%{current: :floor}), do: IO.write(".")
  # defp print_seat(%{current: :open}), do: IO.write("L")
  # defp print_seat(%{current: :used}), do: IO.write("#")
end

Day11.run()
