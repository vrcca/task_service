defmodule TaskService.Domain.ExecutionPlanner do
  alias TaskService.Domain.Node

  def create(tasks) do
    all =
      tasks
      |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.name, task) end)

    nodes =
      tasks_to_nodes(tasks, all, [])
      |> Enum.reverse()

    Node.visit(nodes)
  end

  defp tasks_to_nodes([], _all_tasks, acc), do: acc

  defp tasks_to_nodes(deps = [task | _rest], all_tasks, acc)
       when not is_map(task) do
    Enum.map(deps, fn dep -> Map.get(all_tasks, dep) end)
    |> tasks_to_nodes(all_tasks, acc)
  end

  defp tasks_to_nodes([task | rest], all_tasks, acc) do
    deps =
      tasks_to_nodes(task.dependencies, all_tasks, [])
      |> Enum.reverse()

    tasks_to_nodes(rest, all_tasks, [Node.new(task, deps) | acc])
  end
end
