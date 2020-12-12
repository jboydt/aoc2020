defmodule Day12 do
  @filename "input.txt"

  def run() do
    IO.puts("Day 12\n")

    case process(@filename) do
      {:ok, dist_one, dist_two} ->
        IO.puts("Part 1: distance traveled = #{dist_one}")
        IO.puts("Part 2: waypoint distance traveled = #{dist_two}")

      {:error, reason} ->
        IO.puts("[ERROR] #{reason}")
    end
  end

  defp process(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        instructions =
          contents
          |> String.trim()
          |> String.split("\n")
          |> make_instructions()

        dest_one =
          instructions
          |> travel(%{facing: :east, x: 0, y: 0})

        dest_two =
          instructions
          |> travel_waypoint(%{x: 0, y: 0, wx: 10, wy: 1, orient: :east})

        {
          :ok,
          compute_manhattan_distance(dest_one.x, dest_one.y),
          compute_manhattan_distance(dest_two.x, dest_two.y)
        }

      error ->
        error
    end
  end

  defp compute_manhattan_distance(x, y) do
    abs(x) + abs(y)
  end

  defp travel_waypoint(instructions, way) do
    instructions
    |> Enum.reduce(way, fn i, acc ->
      move_waypoint(i, acc)
    end)
  end

  defp move_waypoint(%{direction: "N", distance: d}, way) do
    %{way | wy: way.wy + d}
  end

  defp move_waypoint(%{direction: "S", distance: d}, way) do
    %{way | wy: way.wy - d}
  end

  defp move_waypoint(%{direction: "E", distance: d}, way) do
    %{way | wx: way.wx + d}
  end

  defp move_waypoint(%{direction: "W", distance: d}, way) do
    %{way | wx: way.wx - d}
  end

  defp move_waypoint(%{direction: "L", distance: d}, way) do
    rotate_left(way, d)
  end

  defp move_waypoint(%{direction: "R", distance: d}, way) do
    rotate_right(way, d)
  end

  defp move_waypoint(%{direction: "F", distance: d}, way) do
    %{way | x: way.x + way.wx * d, y: way.y + way.wy * d}
  end

  defp rotate_left(%{orient: :north} = way, degrees) do
    case degrees do
      90 -> %{way | wx: -way.wy, wy: way.wx, orient: :west}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :south}
      270 -> %{way | wx: way.wy, wy: -way.wx, orient: :east}
      _ -> way
    end
  end

  defp rotate_left(%{orient: :south} = way, degrees) do
    case degrees do
      90 -> %{way | wx: -way.wy, wy: way.wx, orient: :east}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :north}
      270 -> %{way | wx: way.wy, wy: -way.wx, orient: :west}
      _ -> way
    end
  end

  defp rotate_left(%{orient: :east} = way, degrees) do
    case degrees do
      90 -> %{way | wx: -way.wy, wy: way.wx, orient: :north}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :west}
      270 -> %{way | wx: way.wy, wy: -way.wx, orient: :south}
      _ -> way
    end
  end

  defp rotate_left(%{orient: :west} = way, degrees) do
    case degrees do
      90 -> %{way | wx: -way.wy, wy: way.wx, orient: :south}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :east}
      270 -> %{way | wx: way.wy, wy: -way.wx, orient: :north}
      _ -> way
    end
  end

  defp rotate_right(%{orient: :north} = way, degrees) do
    case degrees do
      90 -> %{way | wx: way.wy, wy: -way.wx, orient: :east}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :south}
      270 -> %{way | wx: -way.wy, wy: way.wx, orient: :west}
      _ -> way
    end
  end

  defp rotate_right(%{orient: :south} = way, degrees) do
    case degrees do
      90 -> %{way | wx: way.wy, wy: -way.wx, orient: :east}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :north}
      270 -> %{way | wx: -way.wy, wy: way.wx, orient: :west}
      _ -> way
    end
  end

  defp rotate_right(%{orient: :east} = way, degrees) do
    case degrees do
      90 -> %{way | wx: way.wy, wy: -way.wx, orient: :south}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :west}
      270 -> %{way | wx: -way.wy, wy: way.wx, orient: :north}
      _ -> way
    end
  end

  defp rotate_right(%{orient: :west} = way, degrees) do
    case degrees do
      90 -> %{way | wx: way.wy, wy: -way.wx, orient: :north}
      180 -> %{way | wx: -way.wx, wy: -way.wy, orient: :east}
      270 -> %{way | wx: -way.wy, wy: way.wx, orient: :south}
      _ -> way
    end
  end

  defp travel(instructions, current) do
    instructions
    |> Enum.reduce(current, fn i, acc ->
      move(i, acc)
    end)
  end

  defp move(%{direction: "N", distance: d}, curr), do: %{curr | x: curr.x + d}
  defp move(%{direction: "S", distance: d}, curr), do: %{curr | x: curr.x - d}
  defp move(%{direction: "E", distance: d}, curr), do: %{curr | y: curr.y + d}
  defp move(%{direction: "W", distance: d}, curr), do: %{curr | y: curr.y - d}
  defp move(%{direction: "L", distance: d}, curr), do: turn_left(curr, d)
  defp move(%{direction: "R", distance: d}, curr), do: turn_right(curr, d)

  defp move(%{direction: "F", distance: d}, curr) do
    case curr.facing do
      :north -> move(%{direction: "N", distance: d}, curr)
      :south -> move(%{direction: "S", distance: d}, curr)
      :east -> move(%{direction: "E", distance: d}, curr)
      :west -> move(%{direction: "W", distance: d}, curr)
      true -> curr
    end
  end

  defp turn_left(%{facing: :north} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :west}
      180 -> %{curr | facing: :south}
      270 -> %{curr | facing: :east}
      _ -> curr
    end
  end

  defp turn_left(%{facing: :south} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :east}
      180 -> %{curr | facing: :north}
      270 -> %{curr | facing: :west}
      _ -> curr
    end
  end

  defp turn_left(%{facing: :east} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :north}
      180 -> %{curr | facing: :west}
      270 -> %{curr | facing: :south}
      _ -> curr
    end
  end

  defp turn_left(%{facing: :west} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :south}
      180 -> %{curr | facing: :east}
      270 -> %{curr | facing: :north}
      _ -> curr
    end
  end

  defp turn_right(%{facing: :north} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :east}
      180 -> %{curr | facing: :south}
      270 -> %{curr | facing: :west}
      _ -> curr
    end
  end

  defp turn_right(%{facing: :south} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :west}
      180 -> %{curr | facing: :north}
      270 -> %{curr | facing: :east}
      _ -> curr
    end
  end

  defp turn_right(%{facing: :east} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :south}
      180 -> %{curr | facing: :west}
      270 -> %{curr | facing: :north}
      _ -> curr
    end
  end

  defp turn_right(%{facing: :west} = curr, degrees) do
    case degrees do
      90 -> %{curr | facing: :north}
      180 -> %{curr | facing: :east}
      270 -> %{curr | facing: :south}
      _ -> curr
    end
  end

  defp make_instructions(input) do
    input
    |> Enum.reduce([], fn i, acc ->
      acc ++ [make_instruction(i)]
    end)
  end

  defp make_instruction(input) do
    {dir, dist} = String.split_at(input, 1)
    %{direction: dir, distance: String.to_integer(dist)}
  end
end

Day12.run()
