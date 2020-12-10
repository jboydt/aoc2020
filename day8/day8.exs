defmodule Day8 do
  @filename "input.txt"

  def run() do
    IO.puts("Day 8\n")

    case process(@filename) do
      {:ok, acc, fixed_acc} ->
        IO.puts("Part 1: accumulator = #{acc}")
        IO.puts("Part 2: accumulator after fix = #{fixed_acc}")

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
          |> String.downcase()
          |> String.split("\n")
          |> build_program([], 1)

        {:halted, acc} =
          instructions
          |> execute(1, 0)

        fixed_acc =
          instructions
          |> fix_and_execute(1)

        {:ok, acc, fixed_acc}

      error ->
        error
    end
  end

  defp fix_and_execute(instructions, next_fix) do
    {fixed_instructions, last_fix} = fix_instruction_at(instructions, next_fix)

    case execute(fixed_instructions, 1, 0) do
      {:completed, acc} ->
        acc

      {:halted, _} ->
        fix_and_execute(instructions, last_fix)
    end
  end

  defp fix_instruction_at(instructions, line) do
    updated_instruction =
      case find_next_instruction(instructions, line) do
        {:nop, instruction} -> %{instruction | op: "jmp"}
        {:jmp, instruction} -> %{instruction | op: "nop"}
      end

    updated_instructions =
      instructions
      |> Enum.map(fn i ->
        if i.line == updated_instruction.line do
          updated_instruction
        else
          i
        end
      end)

    {updated_instructions, updated_instruction.line + 1}
  end

  defp find_next_instruction([%{op: "nop", line: line} = instruction | _rest], from)
       when line >= from do
    {:nop, instruction}
  end

  defp find_next_instruction([%{op: "jmp", line: line} = instruction | _rest], from)
       when line >= from do
    {:jmp, instruction}
  end

  defp find_next_instruction([_instruction | rest], from) do
    find_next_instruction(rest, from)
  end

  defp execute(instructions, line, acc) do
    if line > Enum.count(instructions) do
      {:completed, acc}
    else
      instruction =
        instructions
        |> Enum.filter(&(&1.line == line))
        |> List.first()

      case execute_instruction(instruction, line, acc) do
        {:ok, next_line, acc} ->
          updated_instructions =
            instructions
            |> Enum.map(fn i ->
              if i.line == line do
                %{i | exe: i.exe + 1}
              else
                i
              end
            end)

          execute(updated_instructions, next_line, acc)

        {:stop, _line, acc} ->
          {:halted, acc}
      end
    end
  end

  defp execute_instruction(%{exe: exe}, line, acc) when exe > 0 do
    {:stop, line, acc}
  end

  defp execute_instruction(%{op: "nop"}, line, acc) do
    {:ok, line + 1, acc}
  end

  defp execute_instruction(%{op: "acc", arg: arg}, line, acc) do
    {:ok, line + 1, acc + arg}
  end

  defp execute_instruction(%{op: "jmp", arg: arg}, line, acc) do
    {:ok, line + arg, acc}
  end

  defp build_program([], program, _line), do: program

  defp build_program([instruction | rest], program, line) do
    {op, arg} = parse_instruction(instruction)

    build_program(
      rest,
      program ++ [%{op: op, arg: arg, line: line, exe: 0}],
      line + 1
    )
  end

  defp parse_instruction(instruction) do
    [op, arg] = String.split(instruction)
    parsed_arg = parse_argument(arg)
    {op, parsed_arg}
  end

  defp parse_argument("+" <> value), do: String.to_integer(value)
  defp parse_argument("-" <> _rest = value), do: String.to_integer(value)
end

Day8.run()
