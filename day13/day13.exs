defmodule Day13 do
  @filename "input.txt"

  def run() do
    IO.puts("Day 13\n")

    case process(@filename) do
      {:ok, first_bus, timestamp} ->
        IO.puts("Part 1: bus * time waited = #{first_bus}")
        IO.puts("Part 2: earliest time for sequence = #{timestamp}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        schedule =
          contents
          |> String.trim()
          |> String.split("\n")
          |> make_schedule()

        first_bus =
          schedule
          |> run_schedule()
          |> solve_part_one(schedule.depart)

        {_, step, _} = schedule.buses |> List.first()

        timestamp =
          schedule.buses
          |> Enum.drop(1)
          |> find_timestamp(step, step)

        {:ok, first_bus, timestamp}

      error ->
        error
    end
  end

  defp solve_part_one({_idx, bid, time}, depart) do
    (time - depart) * bid
  end

  defp find_timestamp([], time, _), do: time

  defp find_timestamp([{i, b, _} | rest] = buses, time, step) do
    case correct_step(time, i, b) do
      true -> find_timestamp(rest, time, lcm(step, b))
      false -> find_timestamp(buses, time + step, step)
    end
  end

  defp correct_step(time, i, b) do
    cond do
      rem(time + i, b) == 0 -> true
      true -> false
    end
  end

  defp run_schedule(%{depart: depart, buses: buses}) do
    buses
    |> Enum.map(fn {idx, bid, _time} -> {idx, bid, ceil(depart / bid) * bid} end)
    |> Enum.filter(fn {_idx, _bid, time} -> time >= depart end)
    |> Enum.sort_by(fn {_idx, _bid, time} -> time end)
    |> List.first()
  end

  defp make_schedule([depart, buses]) do
    %{buses: buses} =
      buses
      |> String.split(",")
      |> Enum.reduce(%{next: 0, buses: []}, fn b, acc ->
        %{next: acc.next + 1, buses: acc.buses ++ [{acc.next, b}]}
      end)
      |> Map.drop([:next])

    ready_buses =
      buses
      |> Enum.filter(fn {_n, b} -> b != "x" end)
      |> Enum.map(fn {n, b} -> {n, String.to_integer(b), 0} end)

    %{depart: String.to_integer(depart), buses: ready_buses}
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))
end

Day13.run()
