defmodule TaskService.Domain.ExecutionPlanner do
  def create(tasks) do
    all =
      tasks
      |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.name, task) end)

    tasks
    |> plan(all, {[], %{}})
    |> elem(0)
    |> Enum.reverse()
  end

  defp plan([], _all, acc), do: acc

  defp plan([dep | rest], all, acc) when not is_map(dep) do
    plan(rest, all, plan_task(all[dep], all, acc))
  end

  defp plan([task | rest], all, acc) do
    plan(rest, all, plan_task(task, all, acc))
  end

  defp plan_task(task = %{dependencies: deps}, all, acc) when is_list(deps) do
    plan_task(Map.delete(task, :dependencies), all, plan(deps, all, acc))
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
