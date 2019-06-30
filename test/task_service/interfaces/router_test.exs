defmodule TaskService.Interfaces.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias TaskService.Interfaces.Router

  @opts Router.init([])

  test "returns 404 for unknown routes" do
    conn = conn(:get, "/unknown-route")
    conn = Router.call(conn, @opts)
    assert %Plug.Conn{status: 404} = conn
  end
end
