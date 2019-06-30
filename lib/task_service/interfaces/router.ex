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
    json_decoder: Poison
  )

  plug(:dispatch)

  get "/tasks/hello" do
    send_resp(conn, 200, "World!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
