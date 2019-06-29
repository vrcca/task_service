defmodule TaskService.Domain.Node do
  alias TaskService.Domain.Node

  defstruct root: nil, edges: []

  def new(root, edges \\ []) do
    %Node{root: root, edges: edges}
  end

  def visit(nodes) do
    {acc, _visited} = visit(nodes, {[], %{}})

    acc
    |> Enum.reverse()
  end

  defp visit([], acc), do: acc

  defp visit([node | rest], acc) do
    updated_acc = visit(node, acc)
    visit(rest, updated_acc)
  end

  defp visit(node = %Node{root: _root, edges: edges}, acc) do
    root = Map.delete(node, :edges)
    visit(root, visit(edges, acc))
  end

  defp visit(%Node{root: root}, {acc, visited}) do
    unless Map.has_key?(visited, root) do
      visited = Map.put(visited, root, true)
      acc = [root | acc]
      {acc, visited}
    else
      {acc, visited}
    end
  end
end
