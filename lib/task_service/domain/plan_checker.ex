defmodule TaskService.Domain.PlanChecker do
  def check(acc, %{name: name}), do: check_cycle(acc, name)

  def check(acc, dependency) when not is_map(dependency) do
    acc
    |> check_dependency(dependency)
    |> check_cycle(dependency)
  end

  defp check_cycle(acc = %{processed: processed, seen: seen}, name) do
    has_cycle = (!processed[name] and seen[name]) || false

    case has_cycle do
      true -> Map.put(acc, :error, "Cyclic dependency found at '#{name}'")
      false -> put_in(acc, [:seen, name], true)
    end
  end

  defp check_dependency(acc = %{tasks: tasks}, name) do
    case Map.has_key?(tasks, name) do
      false -> Map.put(acc, :error, "Missing dependency '#{name}'")
      true -> acc
    end
  end
end
