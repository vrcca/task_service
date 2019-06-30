defmodule TaskService.Domain.ExecutionPlannerTest do
  use ExUnit.Case, async: true
  alias TaskService.Domain.ExecutionPlanner
  import Fixtures

  test "empty tasks returns empty plan" do
    tasks = []
    plan = ExecutionPlanner.create(tasks)
    assert [] == plan
  end

  test "returns one command when there is only a task" do
    task1 = a_task("tmp")
    tasks = [task1]
    [plan1] = ExecutionPlanner.create(tasks)
    assert task1 |> no_dependencies() == plan1
  end

  test "returns same order when tasks does not contain dependencies" do
    task1 =
      a_task("tmp")
      |> Map.delete(:requires)

    task2 =
      a_task("rm")
      |> Map.delete(:requires)

    tasks = [task1, task2]
    [plan1, plan2] = ExecutionPlanner.create(tasks)
    assert task1 |> no_dependencies() == plan1
    assert task2 |> no_dependencies() == plan2
  end

  test "returns task2 as first plan due to task1 depending on it" do
    task1 = a_task("task1", requires: ["task2"])
    task2 = a_task("task2")
    tasks = [task1, task2]
    [plan1, plan2] = ExecutionPlanner.create(tasks)
    assert plan1.name == "task2"
    assert plan2.name == "task1"
  end

  test "mixed dependencies" do
    task1 = a_task("task1")
    task2 = a_task("task2", requires: ["task3"])
    task3 = a_task("task3", requires: ["task1"])
    task4 = a_task("task4", requires: ["task2", "task3"])

    tasks = [task1, task2, task3, task4]
    [plan1, plan2, plan3, plan4] = ExecutionPlanner.create(tasks)
    assert plan1.name == "task1"
    assert plan2.name == "task3"
    assert plan3.name == "task2"
    assert plan4.name == "task4"
  end

  test "follows dependencies to the end" do
    task1 = a_task("task1", requires: ["task2"])
    task2 = a_task("task2", requires: ["task3"])
    task3 = a_task("task3", requires: ["task4"])
    task4 = a_task("task4")
    tasks = [task1, task2, task3, task4]
    [plan1, plan2, plan3, plan4] = ExecutionPlanner.create(tasks)
    assert plan1.name == "task4"
    assert plan2.name == "task3"
    assert plan3.name == "task2"
    assert plan4.name == "task1"
  end

  test "does not allow circular dependencies" do
    task1 = a_task("task1", requires: ["task2"])
    task2 = a_task("task2", requires: ["task1"])
    tasks = [task1, task2]

    assert {:error, reason} = ExecutionPlanner.create(tasks)
    assert reason == "Cyclic dependency found at 'task1'"
  end

  test "does not allow deep circular dependencies" do
    task1 = a_task("task1", requires: ["task2"])
    task2 = a_task("task2", requires: ["task3"])
    task3 = a_task("task3", requires: ["task4"])
    task4 = a_task("task4", requires: ["task1"])
    tasks = [task1, task2, task3, task4]

    assert {:error, reason} = ExecutionPlanner.create(tasks)
    assert reason == "Cyclic dependency found at 'task1'"
  end

  test "does not allow missing dependencies" do
    task1 = a_task("task1", requires: ["task2"])
    tasks = [task1]

    assert {:error, reason} = ExecutionPlanner.create(tasks)
    assert reason == "Missing dependency 'task2'"
  end

  defp no_dependencies(task), do: task |> Map.delete(:requires)
end
