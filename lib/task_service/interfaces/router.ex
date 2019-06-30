defmodule TaskService.Interfaces.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/*"],
    json_decoder: Poison
  )

  plug(:dispatch)

  post "/plans" do
    tasks =
      conn
      |> parse_body()
      |> Map.get("tasks")
      |> Enum.map(&to_domain/1)

    body =
      TaskService.Domain.ExecutionPlanner.create(tasks)
      |> to_response(conn)

    conn
    |> send_resp(201, body)
  end

  defp parse_body(%{body_params: body}) do
    [urlencoded_body | _rest] = body |> Map.keys()
    Poison.decode!(urlencoded_body)
  end

  defp to_response(plan, _conn) do
    """
    #!/usr/bin/env bash

    #{to_bash(plan)}
    """
  end

  defp to_bash(plan) do
    plan
    |> Stream.map(fn task -> task.command end)
    |> Enum.join("\n")
  end

  defp to_domain(tasks) do
    Enum.into(tasks, %{}, fn {key, val} ->
      {String.to_atom(key), val}
    end)
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
