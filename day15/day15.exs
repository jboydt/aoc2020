defmodule Day15 do
  @filename "input.txt"
  @last_turn 2020
  @big_last_turn 30_000_000

  def run() do
    IO.puts("Day 15\n")

    case process(@filename) do
      {:ok, result_one, result_two} ->
        IO.puts("Part 1: #{result_one} spoken on turn #{@last_turn}")
        IO.puts("Part 2: #{result_two} spoken on turn #{@big_last_turn}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        %{nums: numbers} =
          contents
          |> String.trim()
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
          |> Enum.reduce(%{idx: 1, nums: []}, fn n, acc ->
            %{idx: acc.idx + 1, nums: acc.nums ++ [{acc.idx, n}]}
          end)

        {_, result_one} =
          numbers
          |> count_to(1, @last_turn)

        {_, result_two} =
          numbers
          |> count_to(1, @big_last_turn)

        {:ok, result_one, result_two}

      error ->
        error
    end
  end

  defp count_to(numbers, turn, last) when turn == last do
    List.last(numbers)
  end

  defp count_to(numbers, turn, last) do
    if rem(turn, 10000) == 0 do
      IO.puts("turn = #{turn}")
    end

    cond do
      Enum.count(numbers) > turn -> count_to(numbers, turn + 1, last)
      true -> count_to(next_number(numbers, turn + 1), turn + 1, last)
    end
  end

  defp next_number(numbers, turn) do
    case times_occurs(numbers, List.last(numbers)) do
      1 ->
        # IO.puts("turn #{turn} -> 0")
        numbers ++ [{turn, 0}]

      _ ->
        {i, n} = diff_of_last_two(numbers, turn)
        # IO.puts("turn #{turn} -> #{n}")
        numbers ++ [{i, n}]
    end
  end

  defp times_occurs(numbers, {_, target}) do
    numbers
    |> Enum.reduce(0, fn {_, n}, acc ->
      if n == target do
        acc + 1
      else
        acc
      end
    end)
  end

  defp diff_of_last_two(numbers, turn) do
    {_, target} = List.last(numbers)

    [{i1, _}, {i2, _}] =
      numbers
      |> Enum.reject(fn {_, n} ->
        n != target
      end)
      |> Enum.take(-2)

    {turn, i2 - i1}
  end
end

Day15.run()
