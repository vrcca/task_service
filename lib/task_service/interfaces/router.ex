defmodule TaskService.Interfaces.Router do
  use Plug.Router
  alias TaskService.Interfaces.{TasksRequestConverter, TasksResponseConverter}
  alias TaskService.Domain.ExecutionPlanner

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
    with {:ok, tasks} <- TasksRequestConverter.convert(conn),
         {:ok, plan} <- ExecutionPlanner.create(tasks),
         body <- TasksResponseConverter.convert(conn, plan) do
      send_resp(conn, 201, body)
    else
      {:error, reason} -> send_resp(conn, 400, reason)
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
