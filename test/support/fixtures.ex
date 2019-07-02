defmodule Fixtures do
  use Plug.Test

  def a_task(name, opts \\ []) do
    requires = Keyword.get(opts, :requires) || []
    opts = Enum.into(opts, %{})

    task = %{
      name: name,
      command: "touch /tmp/#{name}",
      requires: requires
    }

    Map.merge(task, opts)
  end

  def a_plan_request_with_tasks(tasks) do
    conn(:post, "/plans", %{tasks: tasks})
    |> put_json_header()
    |> put_req_header("accept", "text/plain")
  end

  def to_json(term), do: Jason.encode!(term)
  def to_map(json), do: Jason.decode!(json)
  def with_no_dependencies(task), do: Map.delete(task, :requires)

  def put_json_header(conn) do
    put_req_header(conn, "content-type", "application/json")
  end
end
