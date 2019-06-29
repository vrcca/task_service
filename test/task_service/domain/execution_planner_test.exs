defmodule TaskService.ExecutionPlannerTest do
  use ExUnit.Case
  alias TaskService.ExecutionPlanner

  test "returns one command when there is only one" do
    tasks = [
      %{
        name: "task-1",
        command: "touch /tmp/file"
      }
    ]

    plan = ExecutionPlanner.create(tasks)
    assert ^tasks = plan
  end
end
