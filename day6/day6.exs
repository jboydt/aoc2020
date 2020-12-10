defmodule Day6 do
  @filename "input.txt"

  def run() do
    IO.puts("Day 6\n")

    case process(@filename) do
      {:ok, yes, everyone} ->
        IO.puts("Part 1: sum of yes answers is #{yes}")
        IO.puts("Part 2: sum of everyone answers yes is #{everyone}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        groups =
          contents
          |> String.trim()
          |> String.downcase()
          |> String.split("\n\n")

        yes =
          groups
          |> Enum.map(&String.replace(&1, "\n", ""))
          |> Enum.map(&count_unique_answers(&1))
          |> Enum.reduce(0, fn m, acc -> Enum.count(m) + acc end)

        everyone =
          groups
          |> Enum.map(&all_yes(&1))
          |> Enum.reduce(fn c, acc -> c + acc end)

        {:ok, yes, everyone}

      error ->
        error
    end
  end

  defp all_yes(group) do
    members = 1 + (group |> String.graphemes() |> Enum.count(&(&1 == "\n")))

    group
    |> String.replace("\n", "")
    |> count_unique_answers()
    |> Enum.filter(fn {_k, v} -> v == members end)
    |> Enum.count()
  end

  defp count_unique_answers(group) do
    group
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, acc ->
      Map.update(acc, char, 1, &(&1 + 1))
    end)
  end
end

Day6.run()
