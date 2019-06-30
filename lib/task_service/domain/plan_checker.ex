defmodule TaskService.Domain.PlanChecker do
  def check(plan, _task = %{name: name}), do: check_cycle(plan, name)

  def check(plan, dependency) when not is_map(dependency) do
    plan
    |> check_dependency(dependency)
    |> check_cycle(dependency)
  end

  defp check_cycle(plan = %{error: _reason}, _task), do: plan

  defp check_cycle(plan = %{processed: processed, seen: seen}, task) do
    has_cycle = (!processed[task] and seen[task]) || false

    case has_cycle do
      true -> Map.put(plan, :error, "Cyclic dependency found at '#{task}'")
      _ -> put_in(plan, [:seen, task], true)
    end
  end

  defp check_dependency(plan = %{tasks: tasks}, task) do
    cond do
      not Map.has_key?(tasks, task) -> Map.put(plan, :error, "Missing dependency '#{task}'")
      true -> plan
    end
  end
end
