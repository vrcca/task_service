defmodule TaskService.ExecutionPlanner do
  alias TaskService.Domain.Node

  def create(tasks) do
    all =
      tasks
      |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.name, task) end)

    nodes =
      tasks
      |> Enum.map(fn task ->
        deps = Enum.map(task.dependencies, fn dep -> Node.new(dep) end)
        Node.new(task.name, deps)
      end)

    Node.visit(nodes)
    |> Enum.map(fn name -> Map.get(all, name) end)
  end
end
