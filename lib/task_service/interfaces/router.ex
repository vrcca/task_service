defmodule TaskService.Interfaces.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/plans" do
    tasks =
      conn
      |> Map.get(:body_params)
      |> Map.get("tasks")
      |> process()
      |> to_response(conn)

    conn
    |> respond(tasks)
  end

  defp process(nil), do: {:error, 400, "No 'tasks' list found."}

  defp process(tasks) do
    tasks
    |> Enum.map(&to_domain/1)
    |> TaskService.Domain.ExecutionPlanner.create()
  end

  defp respond(conn, {:error, code, reason}) do
    conn
    |> send_resp(code, reason)
  end

  defp respond(conn, body) do
    conn
    |> send_resp(201, body)
  end

  defp to_response(error = {:error, _code, _reason}, _conn), do: error

  defp to_response(plan, conn = %Plug.Conn{}) do
    plain =
      get_req_header(conn, "accept")
      |> Enum.any?(fn header ->
        String.downcase(header) == "text/plain"
      end)

    case plain do
      true -> to_bash(plan)
      false -> Jason.encode!(plan)
    end
  end

  defp to_bash(plan) do
    """
    #!/usr/bin/env bash

    #{to_bash_tasks(plan)}
    """
  end

  defp to_bash_tasks(plan) do
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
