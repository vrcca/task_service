defmodule TaskService.Application do
  @moduledoc false

  use Application
  alias TaskService.Interfaces.Router

  def start(_type, _args) do
    port = port()

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: TaskService.Supervisor]

    with result = {:ok, _pid} <- Supervisor.start_link(children, opts) do
      IO.puts("Server started at port #{port}")
      result
    end
  end

  defp port() do
    Application.get_env(:task_service, :port, "4001")
    |> String.to_integer()
  end
end
