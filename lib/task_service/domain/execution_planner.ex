defmodule TaskService.Domain.ExecutionPlanner do
  def create(tasks) do
    acc = %{tasks: create_map(tasks), plans: [], visited: %{}}

    plan(tasks, acc)
    |> Map.get(:plans)
    |> Enum.reverse()
  end

  defp create_map(tasks) do
    Enum.reduce(tasks, %{}, fn task, acc -> Map.put(acc, task.name, task) end)
  end

  defp plan([], acc), do: acc

  defp plan([dep | rest], acc = %{tasks: tasks}) when not is_map(dep) do
    plan(rest, plan_task(tasks[dep], acc))
  end

  defp plan([task | rest], acc) do
    plan(rest, plan_task(task, acc))
  end

  defp plan_task(task = %{dependencies: deps}, acc) when is_list(deps) do
    planned_deps = plan(deps, acc)
    task_only = Map.delete(task, :dependencies)
    plan_task(task_only, planned_deps)
  end

  defp plan_task(task = %{}, acc = %{visited: visited}) do
    unless Map.has_key?(visited, task) do
      acc
      |> put_in([:visited, task], true)
      |> update_in([:plans], &[task | &1])
    else
      acc
    end
  end
end
