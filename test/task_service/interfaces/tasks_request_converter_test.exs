defmodule TaskService.Interfaces.TasksRequestConverterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias TaskService.Interfaces.TasksRequestConverter
  import Fixtures

  test "translates list correctly" do
    task1 = a_task("task1")
    conn = a_plan_request_with_tasks([task1])
    {:ok, translated_tasks} = TasksRequestConverter.convert(conn)
    assert translated_tasks == [task1]
  end

  test "nil lists return error" do
    assert {:error, reason} = TasksRequestConverter.convert(a_plan_request_with_tasks(nil))
    assert reason == "nil task list"
  end

  test "missing \"name\" property return error" do
    tasks = a_plan_request_with_tasks([%{naem: "task1", command: ""}])
    assert {:error, reason} = TasksRequestConverter.convert(tasks)
    assert reason == "Task is missing 'name' property."
  end

  test "missing \"command\" property return error" do
    tasks = a_plan_request_with_tasks([%{name: "task1", commad: ""}])
    assert {:error, reason} = TasksRequestConverter.convert(tasks)
    assert reason == "Task is missing 'command' property."
  end

  test "dependencies are translated" do
    task1 = a_task("task1", requires: ["task2"])
    task2 = a_task("task2")
    tasks = [task1, task2]

    {:ok, translated_tasks} =
      tasks
      |> a_plan_request_with_tasks()
      |> TasksRequestConverter.convert()

    assert translated_tasks == tasks
  end

  test "missing property error is detected on first task" do
    task1 = %{nam: "task1", command: ""}
    task2 = %{name: "task2", comman: ""}
    tasks = a_plan_request_with_tasks([task1, task2])
    assert {:error, reason} = TasksRequestConverter.convert(tasks)
    assert reason == "Task is missing 'name' property."
  end

  test "missing property error is detected on second task" do
    task1 = %{name: "task1", command: ""}
    task2 = %{name: "task2", comman: ""}
    tasks = a_plan_request_with_tasks([task1, task2])
    assert {:error, reason} = TasksRequestConverter.convert(tasks)
    assert reason == "Task is missing 'command' property."
  end
end
