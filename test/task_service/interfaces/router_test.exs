defmodule TaskService.Interfaces.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Fixtures
  alias TaskService.Interfaces.Router

  @opts Router.init([])

  test "returns 404 for unknown routes" do
    conn = conn(:get, "/unknown-route")
    conn = Router.call(conn, @opts)
    assert conn.status == 404
  end

  test "POST /plans returns bash script for text/plain" do
    task1 = a_task("task-1", command: "touch /tmp/file1")
    tasks = %{tasks: [task1]}

    conn =
      :post
      |> conn("/plans", to_json(tasks))
      |> put_json_header()
      |> put_req_header("accept", "text/plain")
      |> Router.call(@opts)

    assert conn.status == 201

    assert conn.resp_body == """
           #!/usr/bin/env bash

           #{task1.command}
           """
  end

  test "POST /plans returns JSON by default" do
    task1 = a_task("task-1", command: "touch /tmp/file1")
    tasks = %{tasks: [task1]}

    conn =
      :post
      |> conn("/plans", to_json(tasks))
      |> put_json_header()
      |> Router.call(@opts)

    assert conn.status == 201
    assert conn.resp_body == to_json([with_no_dependencies(task1)])
  end

  test "POST /plans returns 400 for bad requests" do
    tasks = %{missing_root_tasks_property: []}

    conn =
      :post
      |> conn("/plans", to_json(tasks))
      |> put_json_header()
      |> Router.call(@opts)

    assert conn.status == 400
    assert to_map(conn.resp_body) == %{"error" => "nil task list"}
  end

  test "POST /plans returns 400 for invalid tasks" do
    tasks = %{tasks: [%{naem: "task1", command: "tmp"}]}

    conn =
      :post
      |> conn("/plans", to_json(tasks))
      |> put_json_header()
      |> put_req_header("accept", "text/plain")
      |> Router.call(@opts)

    assert conn.status == 400
    assert conn.resp_body =~ "Task is missing"
  end

  test "POST /plans returns 400 for cyclic dependencies" do
    task1 = a_task("task-1", requires: ["task-2"])
    task2 = a_task("task-2", requires: ["task-1"])
    tasks = %{tasks: [task1, task2]}

    conn =
      :post
      |> conn("/plans", to_json(tasks))
      |> put_json_header()
      |> Router.call(@opts)

    assert conn.status == 400
    assert conn.resp_body =~ "Cyclic dependency found"
  end
end
