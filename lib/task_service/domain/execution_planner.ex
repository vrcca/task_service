defmodule TaskService.Domain.ExecutionPlanner do
  alias TaskService.Domain.Node

  def create(tasks) do
    all =
      tasks
      |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.name, task) end)

    nodes =
      tasks
      |> Enum.map(fn task ->
        deps = Enum.map(task.dependencies, fn dep -> Node.new(Map.get(all, dep)) end)
        Node.new(task, deps)
      end)

    Node.visit(nodes)
  end
end
