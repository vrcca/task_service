defmodule TaskService.TaskExecutionTest do
  use ExUnit.Case
  alias TaskService.TaskExecution

  test "returns one command when there is only one" do
    tasks = [
      %{
        name: "task-1",
        command: "touch /tmp/file"
      }
    ]

    execution = TaskExecution.create(tasks)
    assert ^tasks = execution
  end
end
