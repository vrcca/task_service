defmodule TaskService.Domain.ExecutionPlanner do
  def create(tasks) do
    all =
      tasks
      |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.name, task) end)

    {acc, _visited} = visit(tasks, all, {[], %{}})

    acc
    |> Enum.reverse()
  end

  defp visit([], _all, acc), do: acc

  defp visit([task | rest], all, acc) do
    visit(rest, all, plan_task(task, all, acc))
  end

  defp plan_task(task = %{dependencies: deps}, all, acc) when is_list(deps) do
    deps = Enum.map(deps, fn dep -> all[dep] end)
    plan_task(Map.delete(task, :dependencies), all, visit(deps, all, acc))
  end

  defp plan_task(task = %{}, _all, {acc, visited}) do
    unless Map.has_key?(visited, task) do
      visited = Map.put(visited, task, true)
      acc = [task | acc]
      {acc, visited}
    else
      {acc, visited}
    end
  end
end
