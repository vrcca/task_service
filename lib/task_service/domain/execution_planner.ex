defmodule TaskService.Domain.ExecutionPlanner do
  alias TaskService.Domain.PlanChecker

  def create(tasks) do
    acc = %{tasks: tasks |> to_map(), plan: [], processed: %{}, seen: %{}}

    plan(tasks, acc)
    |> case do
      %{error: reason} -> {:error, reason}
      %{plan: plan} -> {:ok, Enum.reverse(plan)}
    end
  end

  defp plan([], acc), do: acc

  defp plan(_tasks, acc = %{error: _reason}), do: acc

  defp plan([task | rest], acc) do
    acc = acc |> PlanChecker.check(task)
    task = acc |> get_task(task)
    plan(rest, plan_task(task, acc))
  end

  defp plan_task(_task, acc = %{error: _reason}), do: acc

  defp plan_task(task = %{requires: dependencies}, acc) when is_list(dependencies) do
    planned_dependencies = plan(dependencies, acc)
    task_only = Map.delete(task, :requires)
    plan_task(task_only, planned_dependencies)
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

  defp to_map(tasks) do
    Enum.into(tasks, %{}, fn task -> {task.name, task} end)
  end
end
