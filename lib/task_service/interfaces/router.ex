defmodule TaskService.Interfaces.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(:dispatch)

  post "/plans" do
    tasks = conn.body_params["_json"] |> Enum.map(&to_domain/1)

    body =
      TaskService.Domain.ExecutionPlanner.create(tasks)
      |> to_response(conn)

    conn
    |> send_resp(201, body)
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
