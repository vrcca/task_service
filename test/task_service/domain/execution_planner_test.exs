defmodule TaskService.ExecutionPlannerTest do
  use ExUnit.Case
  alias TaskService.ExecutionPlanner
  import Fixtures

  test "empty tasks returns empty plan" do
    tasks = []
    plan = ExecutionPlanner.create(tasks)
    assert [] == plan
  end

  test "returns one command when there is only a task" do
    tasks = [a_task("tmp")]

    plan = ExecutionPlanner.create(tasks)
    assert ^tasks = plan
  end

  test "returns same order when tasks does not contain dependencies" do
    tasks = [a_task("tmp"), a_task("rm")]
    plan = ExecutionPlanner.create(tasks)
    assert ^tasks = plan
  end
end
