defmodule Day5 do
  @filename "input.txt"

  @min_row 0
  @max_row 127
  @min_col 0
  @max_col 7

  @row_data 7

  def run() do
    IO.puts("Day 5\n")

    case process(@filename) do
      {:ok, high, my_id} ->
        IO.puts("Part 1: the highest seat ID is #{high.id}")
        IO.puts("Part 2: my seat ID is #{my_id}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        all_seats =
          contents
          |> String.trim()
          |> String.upcase()
          |> String.split()
          |> Enum.map(&find_seat(&1))

        high =
          all_seats
          |> Enum.max_by(& &1.id)

        my_id =
          all_seats
          |> Enum.sort_by(& &1.id)
          |> find_id_by_diff(2)

        {:ok, high, my_id}

      error ->
        error
    end
  end

  defp find_id_by_diff([first, second | rest], diff) do
    if second.id - first.id == diff do
      first.id + 1
    else
      find_id_by_diff([second | rest], diff)
    end
  end

  defp find_seat(data) do
    {row_data, col_data} = data |> String.split_at(@row_data)
    row = compute_row(row_data, @min_row, @max_row)
    col = compute_col(col_data, @min_col, @max_col)
    id = row * 8 + col
    %{id: id, row: row, col: col}
  end

  defp compute_col("L", lo, _hi), do: lo
  defp compute_col("R", _lo, hi), do: hi
  defp compute_col("L" <> rest, lo, hi), do: compute_col(rest, lo, lo + div(hi - lo, 2))
  defp compute_col("R" <> rest, lo, hi), do: compute_col(rest, lo + div(hi - lo, 2) + 1, hi)

  defp compute_row("F", lo, _hi), do: lo
  defp compute_row("B", _lo, hi), do: hi
  defp compute_row("F" <> rest, lo, hi), do: compute_row(rest, lo, lo + div(hi - lo, 2))
  defp compute_row("B" <> rest, lo, hi), do: compute_row(rest, lo + div(hi - lo, 2) + 1, hi)
end

Day5.run()
