defmodule TaskService.Interfaces.TasksConverter do
  def to_domain(tasks) do
    tasks
    |> map_tasks_to_domain()
  end

  defp map_tasks_to_domain(nil), do: {:error, "nil task list"}

  defp map_tasks_to_domain(tasks) when is_list(tasks) do
    to_domain(tasks, [])
    |> case do
      error = {:error, _reason} -> error
      converted_tasks -> Enum.reverse(converted_tasks)
    end
  end

  defp to_domain([], acc), do: acc

  defp to_domain([task = %{"name" => name, "command" => command} | rest], acc) do
    dependencies = Map.get(task, "requires", [])
    converted_task = %{name: name, command: command, requires: dependencies}
    to_domain(rest, [converted_task | acc])
  end

  defp to_domain([task | _rest], _acc) do
    missing =
      ["name", "command"]
      |> Enum.filter(fn key -> not Map.has_key?(task, key) end)

    {:error, "Task is missing '#{missing}' property."}
  end
end
