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

  test "returns second task at first position due to first task depending on it" do
    first_task = a_task("rm", dependencies: ["touch"])
    second_task = a_task("touch")
    tasks = [first_task, second_task]
    [first_in_plan, second_in_plan] = ExecutionPlanner.create(tasks)
    assert first_in_plan.name == "touch"
    assert second_in_plan.name == "rm"
  end

  test "longer dependencies" do
    task1 = a_task("task1")
    task2 = a_task("task2", dependencies: ["task3"])
    task3 = a_task("task3", dependencies: ["task1"])
    task4 = a_task("task4", dependencies: ["task2", "task3"])

    tasks = [task1, task2, task3, task4]
    [plan1, plan2, plan3, plan4] = ExecutionPlanner.create(tasks)
    assert plan1.name == "task1"
    assert plan2.name == "task3"
    assert plan3.name == "task2"
    assert plan4.name == "task4"
  end
end
