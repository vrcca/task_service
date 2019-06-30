defmodule TaskService.Interfaces.TasksResponseConverter do
  def convert(%Plug.Conn{}, error = {:error, _reason}) do
    error
  end

  def convert(conn = %Plug.Conn{}, plans) do
    plans
    |> to_response(requires_plain_response_type?(conn))
  end

  defp requires_plain_response_type?(conn) do
    Plug.Conn.get_req_header(conn, "accept")
    |> Enum.any?(fn header ->
      String.downcase(header) == "text/plain"
    end)
  end

  defp to_response(error = {:error, _reason}, _type), do: error

  defp to_response(plan, _requires_plain = true) do
    """
    #!/usr/bin/env bash

    #{to_bash_tasks(plan)}
    """
  end

  defp to_response(plan, _default_type) do
    Jason.encode!(plan)
  end

  defp to_bash_tasks(plan) do
    plan
    |> Stream.map(fn task -> task.command end)
    |> Enum.join("\n")
  end
end
