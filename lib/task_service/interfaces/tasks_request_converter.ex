defmodule TaskService.Interfaces.TasksRequestConverter do
  def convert(conn = %Plug.Conn{}) do
    conn
    |> Map.get(:body_params)
    |> Map.get("tasks")
    |> to_domain([])
    |> case do
      error = {:error, _reason} -> error
      converted_tasks -> {:ok, Enum.reverse(converted_tasks)}
    end
  end

  defp to_domain(nil, _acc), do: {:error, "nil task list"}

  defp to_domain([], acc), do: acc

  defp to_domain([task = %{"name" => name, "command" => command} | rest], acc) do
    dependencies = Map.get(task, "requires", [])
    converted_task = %{name: name, command: command, requires: dependencies}
    to_domain(rest, [converted_task | acc])
  end

  defp to_domain([task | _rest], _acc) do
    missing =
      ["name", "command"]
      |> Enum.filter(fn key -> not Map.has_key?(task, key) end)

    {:error, "Task is missing '#{missing}' property."}
  end
end
