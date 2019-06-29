defmodule TaskService.Domain.ExecutionPlanner do
  def create(tasks) do
    acc = %{tasks: create_task_map(tasks), plans: [], visited: %{}, seen: %{}}

    plan(tasks, acc)
    |> Map.get(:plans)
    |> Enum.reverse()
  end

  defp create_task_map(tasks) do
    Enum.reduce(tasks, %{}, fn task, acc ->
      Map.put(acc, task.name, task)
    end)
  end

  defp plan([], acc), do: acc

  defp plan([task = %{name: name} | rest], acc) when is_map(task) do
    acc = put_in(acc, [:seen, name], true)
    plan(rest, plan_task(task, acc))
  end

  defp plan([dependency | rest], acc = %{tasks: tasks}) do
    check_cycle!(acc, dependency)
    acc = put_in(acc, [:seen, dependency], true)
    task = tasks[dependency]
    plan(rest, plan_task(task, acc))
  end

  defp plan_task(task = %{dependencies: deps}, acc) when is_list(deps) do
    planned_deps = plan(deps, acc)
    task_only = Map.delete(task, :dependencies)
    plan_task(task_only, planned_deps)
  end

  defp plan_task(task = %{name: name}, acc = %{visited: visited}) do
    cond do
      not Map.has_key?(visited, name) ->
        acc
        |> put_in([:visited, name], true)
        |> update_in([:plans], &[task | &1])

      true ->
        acc
    end
  end

  defp check_cycle!(%{visited: visited, seen: seen}, name) do
    if not Map.has_key?(visited, name) and Map.has_key?(seen, name) do
      raise ArgumentError, message: "Cyclic dependencies are not allowed!"
    end
  end
end
