defmodule TaskService.Application do
  @moduledoc false

  use Application
  alias TaskService.Interfaces.Router

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Router, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: TaskService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
