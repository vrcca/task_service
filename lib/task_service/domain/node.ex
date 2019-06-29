defmodule TaskService.Domain.Node do
  alias TaskService.Domain.Node

  defstruct value: nil, edges: []

  def new(value, edges \\ []) do
    %Node{value: value, edges: edges}
  end

  def visit(nodes) do
    visit(nodes, {[], %{}})
    |> elem(0)
    |> Enum.reverse()
  end

  defp visit([], acc), do: acc

  defp visit([node | rest], acc) do
    visit(rest, visit(node, acc))
  end

  defp visit(node = %Node{edges: edges}, acc) do
    visit(Map.delete(node, :edges), visit(edges, acc))
  end

  defp visit(%Node{value: value}, {acc, visited}) do
    unless Map.has_key?(visited, value) do
      visited = Map.put(visited, value, true)
      acc = [value | acc]
      {acc, visited}
    else
      {acc, visited}
    end
  end
end
