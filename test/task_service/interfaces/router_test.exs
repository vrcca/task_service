defmodule TaskService.Interfaces.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Fixtures
  alias TaskService.Interfaces.Router

  @opts Router.init([])

  test "returns 404 for unknown routes" do
    conn = conn(:get, "/unknown-route")
    conn = Router.call(conn, @opts)
    assert %Plug.Conn{status: 404} = conn
  end

  test "POST /plans returns bash script" do
    task1 = a_task("task-1", command: "touch /tmp/file1")
    tasks = %{tasks: [task1]}

    conn =
      :post
      |> conn("/plans", to_json(tasks))
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> Router.call(@opts)

    assert %Plug.Conn{status: 201} = conn

    assert conn.resp_body == """
           #!/usr/bin/env bash

           #{task1.command}
           """
  end

  defp to_json(body), do: Poison.encode!(body)
end
