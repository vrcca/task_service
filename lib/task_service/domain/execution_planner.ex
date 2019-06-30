defmodule TaskService.Domain.ExecutionPlanner do
  alias TaskService.Domain.PlanChecker

  def create(tasks) do
    acc = %{tasks: create_task_map(tasks), plan: [], processed: %{}, seen: %{}}

    plan(tasks, acc)
    |> case do
      %{error: reason} -> {:error, reason}
      %{plan: plan} -> Enum.reverse(plan)
    end
  end

  defp create_task_map(tasks) do
    Enum.reduce(tasks, %{}, fn task, acc ->
      Map.put(acc, task.name, task)
    end)
  end

  defp plan([], acc), do: acc

  defp plan(_tasks, acc = %{error: _reason}), do: acc

  defp plan([task | rest], acc) do
    acc = acc |> PlanChecker.check(task)
    task = acc |> get_task(task)
    plan(rest, plan_task(task, acc))
  end

  defp plan_task(_task, acc = %{error: _reason}), do: acc

  defp plan_task(task = %{dependencies: deps}, acc) when is_list(deps) do
    planned_deps = plan(deps, acc)
    task_only = Map.delete(task, :dependencies)
    plan_task(task_only, planned_deps)
  end

  defp plan_task(task = %{name: name}, acc = %{processed: processed}) do
    cond do
      not Map.has_key?(processed, name) ->
        acc
        |> put_in([:processed, name], true)
        |> update_in([:plan], &[task | &1])

      true ->
        acc
    end
  end

  defp get_task(_acc, task = %{}), do: task
  defp get_task(%{tasks: tasks}, name), do: tasks[name]
end
