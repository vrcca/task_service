defmodule TaskService.Interfaces.TasksConverterTest do
  use ExUnit.Case, async: true

  alias TaskService.Interfaces.TasksConverter
  import Fixtures

  test "translates list correctly" do
    task1 = a_task("task1")
    tasks = replace_atom_by_strings([task1])
    translated_tasks = TasksConverter.to_domain(tasks)
    assert translated_tasks == [task1]
  end

  test "nil lists return error" do
    assert {:error, reason} = TasksConverter.to_domain(nil)
    assert reason == "nil task list"
  end

  test "missing \"name\" property return error" do
    tasks = replace_atom_by_strings([%{naem: "task1", command: ""}])
    assert {:error, reason} = TasksConverter.to_domain(tasks)
    assert reason == "Task is missing 'name' property."
  end

  test "missing \"command\" property return error" do
    tasks = replace_atom_by_strings([%{name: "task1", commad: ""}])
    assert {:error, reason} = TasksConverter.to_domain(tasks)
    assert reason == "Task is missing 'command' property."
  end

  test "dependencies are translated" do
    task1 = a_task("task1", dependencies: ["task2"])
    task2 = a_task("task2")
    tasks = [task1, task2]

    translated_tasks =
      tasks
      |> replace_atom_by_strings()
      |> TasksConverter.to_domain()

    assert translated_tasks == tasks
  end

  test "missing property error is detected on first task" do
    task1 = %{nam: "task1", command: ""}
    task2 = %{name: "task2", comman: ""}
    tasks = replace_atom_by_strings([task1, task2])
    assert {:error, reason} = TasksConverter.to_domain(tasks)
    assert reason == "Task is missing 'name' property."
  end

  test "missing property error is detected on second task" do
    task1 = %{name: "task1", command: ""}
    task2 = %{name: "task2", comman: ""}
    tasks = replace_atom_by_strings([task1, task2])
    assert {:error, reason} = TasksConverter.to_domain(tasks)
    assert reason == "Task is missing 'command' property."
  end

  defp replace_atom_by_strings(tasks) do
    Enum.map(tasks, fn task ->
      Enum.into(task, %{}, fn {key, val} ->
        {Atom.to_string(key), val}
      end)
    end)
  end
end
