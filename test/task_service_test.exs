defmodule TaskServiceTest do
  use ExUnit.Case
  doctest TaskService

  test "greets the world" do
    assert TaskService.hello() == :world
  end
end
