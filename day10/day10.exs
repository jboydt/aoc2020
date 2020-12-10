defmodule Day10 do
  @filename "input.txt"
  @max_diff 3

  def run() do
    IO.puts("Day 10\n")

    case process(@filename) do
      {:ok, jolts, arrangements} ->
        IO.puts("Part 1: jolts = #{jolts}")
        IO.puts("Part 2: arrangements = #{arrangements}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        adapters =
          contents
          |> String.trim()
          |> String.split("\n")
          |> Enum.map(&String.to_integer(&1))
          |> Enum.sort()
          |> chain_adapters(0, @max_diff, [])

        {one_diff, three_diff} =
          adapters
          |> count_diffs(0, {0, 0})

        paths =
          ([0] ++ adapters)
          |> count_paths(@max_diff)

        {:ok, one_diff * three_diff, paths}

      error ->
        error
    end
  end

  defp count_paths([_ | rest] = adapters, diff) do
    result =
      rest
      |> Enum.reduce(%{counts: [1], index: 1}, fn a, acc ->
        %{
          counts: acc.counts ++ [paths_to(adapters, acc, a, diff)],
          index: acc.index + 1
        }
      end)

    List.last(result.counts)
  end

  defp paths_to(adapters, %{counts: c, index: i}, adapter, diff) do
    {from, number} =
      if i < 3 do
        {0, i}
      else
        {i - 3, 3}
      end

    temp_adapters =
      adapters
      |> Enum.slice(from, number)

    temp_counters =
      c
      |> Enum.slice(from, number)

    Enum.zip(temp_adapters, temp_counters)
    |> Enum.reject(fn {a, _c} -> adapter - a > diff end)
    |> Enum.reduce(0, fn {_a, c}, acc -> c + acc end)
  end

  defp count_diffs([], _last, diffs), do: diffs

  defp count_diffs([first | rest], last, {od, td}) when first - last == 1 do
    count_diffs(rest, first, {od + 1, td})
  end

  defp count_diffs([first | rest], last, {od, td}) when first - last == 3 do
    count_diffs(rest, first, {od, td + 1})
  end

  defp chain_adapters([], _last, diff, output) do
    output ++ [List.last(output) + diff]
  end

  defp chain_adapters([first | rest], last, diff, output) do
    if first <= last + diff do
      chain_adapters(rest, first, diff, output ++ [first])
    else
      chain_adapters(rest, last, diff, output)
    end
  end
end

Day10.run()
