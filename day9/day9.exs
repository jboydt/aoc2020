defmodule Day9 do
  @filename "input.txt"
  @preamble_size 25

  def run() do
    IO.puts("Day 9\n")

    case process(@filename) do
      {:ok, first_invalid, weakness} ->
        IO.puts("Part 1: first invalid number = #{first_invalid}")
        IO.puts("Part 2: encryption weakness  = #{weakness}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        numbers =
          contents
          |> String.trim()
          |> String.split("\n")
          |> Enum.map(&String.to_integer(&1))

        first_invalid =
          numbers
          |> find_first_invalid(@preamble_size)

        weakness =
          numbers
          |> find_weakness(first_invalid)

        {:ok, first_invalid, Enum.min(weakness) + Enum.max(weakness)}

      error ->
        error
    end
  end

  defp find_weakness([_first | rest] = numbers, target) do
    numbers
    |> Enum.reduce_while([], fn n, acc ->
      cond do
        Enum.sum(acc) < target -> {:cont, acc ++ [n]}
        Enum.sum(acc) > target -> {:halt, find_weakness(rest, target)}
        Enum.sum(acc) == target -> {:halt, acc}
      end
    end)
  end

  defp find_first_invalid([_first | rest] = numbers, preamble_size) do
    preamble =
      numbers
      |> Enum.take(preamble_size)

    test_value =
      numbers
      |> Enum.split(preamble_size)
      |> elem(1)
      |> List.first()

    case is_valid(preamble, test_value) do
      true -> find_first_invalid(rest, preamble_size)
      false -> test_value
    end
  end

  defp is_valid([], _number), do: false

  defp is_valid([first | rest], number) do
    case Enum.any?(rest, fn n -> n + first == number end) do
      true -> true
      false -> is_valid(rest, number)
    end
  end
end

Day9.run()
